module 0x42::football_card{
    use std::signer;
    use std::debug;

    struct FootBallStar has key, drop{
        name: vector<u8>,
        country: vector<u8>,
        position: u8,
        value: u64
    }

    public fun newStar(
        name: vector<u8>,
        country: vector<u8>,
        position: u8
    ): FootBallStar{
        FootBallStar{
            name,
            country,
            position,
            value:0
        }
    }

    public fun mint(to: &signer, star: FootBallStar){
        let acc_addr = signer::address_of(to);
        assert!(!card_exists(acc_addr), 0);
        move_to<FootBallStar>(to, star);
    }
    inline fun card_exists(addr: address):bool{
        exists<FootBallStar>(addr)
    }

    public fun get(owner: &signer):(vector<u8>,u64) acquires FootBallStar{
        let acc_addr = signer::address_of(owner);
        assert!(card_exists(acc_addr), 1);
        let star = borrow_global<FootBallStar>(acc_addr);
        (star.name, star.value)
    }

    public fun setPrice(owner: &signer, price: u64) acquires FootBallStar{
        let acc_addr = signer::address_of(owner);
        assert!(card_exists(acc_addr), 1);
        let star = borrow_global_mut<FootBallStar>(acc_addr);
        star.value = price;
    }

    public fun transfer(owner: &signer, to: &signer) acquires FootBallStar{
        let acc_addr = signer::address_of(owner);
        assert!(card_exists(acc_addr), 1);
        let star = move_from<FootBallStar>(acc_addr);
        let acc_addr2 = signer::address_of(to);
        move_to<FootBallStar>(to,star);
        assert!(card_exists(acc_addr2), 2);
    }

    #[test(owner=@0x23, to=@0x43)]
     fun test_football(owner: signer,to: signer)acquires FootBallStar{
        let star = newStar(b"Sunil Chhetri",b"India",2);
        mint(&owner,star);
        let (name,value) = get(&owner);
        debug::print(&name);
        debug::print(&value);
        setPrice(&owner,10);
        transfer(&owner,&to); 
        let (name,value) = get(&to);
        debug::print(&name);
        debug::print(&value);
    }
}