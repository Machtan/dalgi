local M = {}

-- global defaults to true
function M.ffi_load_without_closing(ffi, path, global)
    ffi.cdef([[
        void *dlopen(const char *, int);
    ]])
    
    -- LuaJIT unloads each loaded library with `dlclose` when the
    -- handle is garbage-collected, but if the library has set
    -- global state (e.g. thread-local finalizers), things can get
    -- ugly, since this state can still be used, but no longer exists.
    --
    -- By calling `dlopen` with the same path, we increment its
    -- reference count, meaning it won't be unloaded with the automatic
    -- call to `dlclose`, but would require another. This means the
    -- library will b loaded for the entirety of the program.
    ffi.C.dlopen(path, 1)
    
    return ffi.load(path, global)
end

return M