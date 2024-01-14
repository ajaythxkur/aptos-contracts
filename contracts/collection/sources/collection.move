module 0x42::Collection{
    use std::signer;
    use std::vector;

    struct Item has store, drop {}
    struct Collection has key{
        items: vector<Item>
    }

    public fun start_collection(account: &signer){
        let addr = signer::address_of(account);
        assert!(!exists<Collection>(addr), 0);
        move_to<Collection>(account, Collection{
            items: vector::empty<Item>()
        });
    }
    inline fun exists_at(at: address): bool{
        exists<Collection>(at)
    }

    public fun add_item(account: &signer) acquires Collection{
        let addr = signer::address_of(account);
        assert!(exists_at(addr), 1);
        let collection = borrow_global_mut<Collection>(addr);
        vector::push_back(&mut collection.items, Item{});
    }

    public fun size(account: &signer):u64 acquires Collection{
        let addr = signer::address_of(account);
        assert!(exists_at(addr), 1); 
        let collection = borrow_global<Collection>(addr);
        vector::length(& collection.items)
    }

    public fun destory(account: &signer) acquires Collection{
        let addr = signer::address_of(account);
        assert!(exists_at(addr), 1); 
        let collection = move_from<Collection>(addr);
        let Collection { items: _ } = collection;
    }

    #[test_only]
    use aptos_framework::account;
    use std::debug::print;
    #[test(acc=@0x12)]
    fun testing(acc:signer) acquires Collection{
        let addr = signer::address_of(&acc);
        account::create_account_for_test(addr);
        start_collection(&acc);
        add_item(&acc);
        print(&size(&acc));
        destory(&acc);
    }
}