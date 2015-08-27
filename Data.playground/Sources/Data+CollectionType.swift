import Dispatch

/// The deallocation routine to use for custom-backed `Data` instances.
public enum UnsafeBufferOwnership<T> {
    /// Copy the buffer passed in; the runtime will manage deallocation.
    case Copy
    /// Dealloc data created by `malloc` or equivalent.
    case Free
    /// Free data created by `mmap` or equivalent.
    case Unmap
    /// Provide some other deallocation routine.
    case Custom(UnsafeBufferPointer<T> -> ())
}

extension Data {
    
    private init(unsafeWithBuffer buffer: UnsafeBufferPointer<T>, queue: dispatch_queue_t, destructor: dispatch_block_t!) {
        let baseAddress = UnsafePointer<Void>(buffer.baseAddress)
        let bytes = buffer.count * sizeof(T)
        self.init(unsafe: dispatch_data_create(baseAddress, bytes, queue, destructor))
    }
    
    private init<Owner: CollectionType>(unsafeWithBuffer buffer: UnsafeBufferPointer<T>, queue: dispatch_queue_t = dispatch_get_global_queue(0, 0), owner: Owner) {
        self.init(unsafeWithBuffer: buffer, queue: queue, destructor: { _ = owner })
    }
    
    /// Create `Data` backed by any arbitrary storage.
    ///
    /// For the `behavior` parameter, pass:
    ///  - `.Copy` to copy the buffer passed in.
    ///  - `.Free` to dealloc data created by `malloc` or equivalent.
    ///  - `.Unmap` to free data created by `mmap` or equivalent.
    ///  - `.Custom` for some custom deallocation.
    public init(unsafeWithBuffer buffer: UnsafeBufferPointer<T>, queue: dispatch_queue_t = dispatch_get_global_queue(0, 0), behavior: UnsafeBufferOwnership<T>) {
        let destructor: dispatch_block_t?
        switch behavior {
        case .Copy:
            destructor = nil
        case .Free:
            destructor = _dispatch_data_destructor_free
        case .Unmap:
            destructor = _dispatch_data_destructor_munmap
        case .Custom(let fn):
            destructor = { fn(buffer) }
        }
        self.init(unsafeWithBuffer: buffer, queue: queue, destructor: destructor)
    }
    
    /// Create `Data` backed by the contiguous contents of an array.
    /// If the array itself is represented discontiguously, the initializer
    /// must first create the storage.
    public init(array: [T]) {
        let buffer = array.withUnsafeBufferPointer { $0 }
        self.init(unsafeWithBuffer: buffer, owner: array)
    }
    
    /// Create `Data` backed by a contiguous array.
    public init(array: ContiguousArray<T>) {
        let buffer = array.withUnsafeBufferPointer { $0 }
        self.init(unsafeWithBuffer: buffer, owner: array)
    }
    
}
