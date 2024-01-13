module store_addrx::storage{
    use std::signer;

    const ERROR:u64 = 101;
    struct Storage<T: store> has key{
        val: T
    }

    fun store<T: store>(acc: &signer, val: T){
        let addr = signer::address_of(acc);
        assert!(!exists<Storage<T>>(addr), ERROR);
        let to_store = Storage {
            val
        };
        move_to(acc, to_store);
    }

    public fun get<T: store>(acc: &signer):T acquires Storage {
        let addr = signer::address_of(acc);
        assert!(exists<Storage<T>>(addr), ERROR);
        let Storage { val } = move_from<Storage<T>>(addr);
        val
    }

    #[test(admin=@store_addrx)]
    fun test_store(admin: signer) acquires Storage{
        let value: u128 = 100;
        store(&admin,value);
        assert!(value == get<u128>(&admin), ERROR);
    }
    
}