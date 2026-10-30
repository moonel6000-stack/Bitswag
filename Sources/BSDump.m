#import "BSDump.h"
#import "BSMenu.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>

typedef void *(*fn_domain_get)(void);
typedef void **(*fn_domain_get_assemblies)(void *, size_t *);
typedef void *(*fn_assembly_get_image)(void *);
typedef const char *(*fn_image_get_name)(void *);
typedef size_t (*fn_image_get_class_count)(void *);
typedef void *(*fn_image_get_class)(void *, size_t);
typedef const char *(*fn_class_get_name)(void *);
typedef const char *(*fn_class_get_namespace)(void *);
typedef void *(*fn_class_get_methods)(void *, void **);
typedef const char *(*fn_method_get_name)(void *);
typedef uint32_t (*fn_method_get_param_count)(void *);
typedef void *(*fn_method_get_param)(void *, uint32_t);
typedef const char *(*fn_method_get_param_name)(void *, uint32_t);
typedef void *(*fn_method_get_return_type)(void *);
typedef uint32_t (*fn_method_get_flags)(void *, uint32_t *);
typedef char *(*fn_type_get_name)(void *);
typedef void *(*fn_thread_attach)(void *);

static void *BSSym(const char *name) {
    void *p = dlsym(RTLD_DEFAULT, name);
    if (!p) BSLogf(@"dump: symbole manquant %s", name);
    return p;
}

static BOOL BSMatch(const char *s, NSArray<NSString *> *keys) {
    if (!s) return NO;
    NSString *str = [NSString stringWithUTF8String:s];
    for (NSString *k in keys) {
        if ([str rangeOfString:k options:NSCaseInsensitiveSearch].location != NSNotFound)
            return YES;
    }
    return NO;
}

NSString *BSDumpIL2CPP(void) {
    fn_domain_get domain_get = BSSym("il2cpp_domain_get");
    fn_domain_get_assemblies get_asm = BSSym("il2cpp_domain_get_assemblies");
    fn_assembly_get_image asm_image = BSSym("il2cpp_assembly_get_image");
    fn_image_get_name image_name = BSSym("il2cpp_image_get_name");
    fn_image_get_class_count class_count = BSSym("il2cpp_image_get_class_count");
    fn_image_get_class image_class = BSSym("il2cpp_image_get_class");
    fn_class_get_name class_name = BSSym("il2cpp_class_get_name");
    fn_class_get_namespace class_ns = BSSym("il2cpp_class_get_namespace");
    fn_class_get_methods class_methods = BSSym("il2cpp_class_get_methods");
    fn_method_get_name m_name = BSSym("il2cpp_method_get_name");
    fn_method_get_param_count m_pcount = BSSym("il2cpp_method_get_param_count");
    fn_method_get_param m_param = BSSym("il2cpp_method_get_param");
    fn_method_get_param_name m_pname = BSSym("il2cpp_method_get_param_name");
    fn_method_get_return_type m_ret = BSSym("il2cpp_method_get_return_type");
    fn_method_get_flags m_flags = BSSym("il2cpp_method_get_flags");
    fn_type_get_name type_name = BSSym("il2cpp_type_get_name");
    fn_thread_attach thread_attach = BSSym("il2cpp_thread_attach");

    if (!domain_get || !get_asm || !asm_image || !image_name || !class_count ||
        !image_class || !class_name || !class_ns || !class_methods || !m_name ||
        !m_pcount || !m_param || !m_ret || !type_name) {
        BSLogf(@"dump: API il2cpp non exportee -> il faudra l'analyse hors appareil");
        return nil;
    }

    // Base/slide de UnityFramework (pour calculer l'adresse virtuelle Il2CppDumper)
    intptr_t slide = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (n && strstr(n, "UnityFramework")) { slide = _dyld_get_image_vmaddr_slide(i); break; }
    }

    void *domain = domain_get();
    if (!domain) { BSLogf(@"dump: domaine il2cpp nul"); return nil; }
    if (thread_attach) thread_attach(domain);

    NSArray<NSString *> *keys = @[
        @"Dealership", @"Vehicle", @"Garage", @"Auction", @"ArtDealer",
        @"ArtMerchant", @"Painting", @"BlackMarket", @"Smuggl",
        @"Happiness", @"Smarts", @"BankBalance", @"Money", @"Wealth"
    ];

    NSMutableString *out = [NSMutableString string];
    [out appendFormat:@"# BitSwag IL2CPP dump, slide UnityFramework=0x%lx\n", (long)slide];
    [out appendString:@"# VA = adresse reelle - slide (comparable a Il2CppDumper)\n"];

    size_t asmCount = 0;
    void **assemblies = get_asm(domain, &asmCount);
    [out appendFormat:@"# assemblies: %zu\n", asmCount];
    NSUInteger lines = 0;

    for (size_t a = 0; a < asmCount && lines < 40000; a++) {
        void *image = asm_image(assemblies[a]);
        const char *iname = image ? image_name(image) : NULL;
        if (!iname || !strstr(iname, "Assembly-CSharp")) continue;
        size_t cc = class_count(image);
        [out appendFormat:@"# image %s, classes: %zu\n", iname, cc];

        for (size_t c = 0; c < cc && lines < 40000; c++) {
            void *klass = image_class(image, c);
            if (!klass) continue;
            const char *cn = class_name(klass);
            const char *ns = class_ns(klass);
            BOOL classMatch = BSMatch(cn, keys) || BSMatch(ns, keys);

            NSMutableString *body = [NSMutableString string];
            BOOL anyMethod = NO;
            void *iter = NULL, *m;
            while ((m = class_methods(klass, &iter))) {
                const char *mn = m_name(m);
                if (!classMatch && !BSMatch(mn, keys)) continue;
                anyMethod = YES;
                void *rt = m_ret(m);
                char *rts = rt ? type_name(rt) : NULL;
                uint32_t iflags = 0;
                uint32_t fl = m_flags ? m_flags(m, &iflags) : 0;
                uintptr_t ptr = *(uintptr_t *)m; // MethodInfo->methodPointer
                NSMutableString *params = [NSMutableString string];
                uint32_t pc = m_pcount(m);
                for (uint32_t p = 0; p < pc; p++) {
                    void *pt = m_param(m, p);
                    char *pts = pt ? type_name(pt) : NULL;
                    const char *pn = m_pname ? m_pname(m, p) : NULL;
                    [params appendFormat:@"%s%s %s", p ? ", " : "",
                        pts ?: "?", pn ?: "_"];
                }
                [body appendFormat:@"  [VA 0x%lx]%s %s %s(%@)\n",
                    ptr ? (long)(ptr - slide) : 0L,
                    (fl & 0x10) ? " static" : "",
                    rts ?: "?", mn ?: "?", params];
                lines++;
            }
            if (classMatch || anyMethod) {
                [out appendFormat:@"\n%s.%s\n%@", ns ?: "", cn ?: "?", body];
            }
        }
    }

    NSString *path = [NSTemporaryDirectory()
        stringByAppendingPathComponent:@"bitswag_il2cpp.txt"];
    NSError *err = nil;
    BOOL ok = [out writeToFile:path atomically:YES
                      encoding:NSUTF8StringEncoding error:&err];
    BSLogf(@"dump: %lu lignes, ecriture=%d (%@) %@", (unsigned long)lines, ok,
           path, err ?: @"");
    return ok ? path : nil;
}
