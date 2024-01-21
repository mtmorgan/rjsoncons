#ifndef RJSONCONS_UTILITIES_H
#define RJSONCONS_UTILITIES_H

// use this to switch() on string values
// https://stackoverflow.com/a/46711735/547331
constexpr unsigned int hash(const char *s, int off = 0)
{
    return !s[off] ? 5381 : (hash(s, off+1)*33) ^ s[off];
}

#endif
