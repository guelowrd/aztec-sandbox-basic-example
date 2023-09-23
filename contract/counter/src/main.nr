// 0x0de76df1a7429f61d17d3a188a9f68aff599ee7ac5bf2f1c573803b8160ba70e

// pk 0x1ccd0152ff01ee25ff146ca7a4ceef4230e3dc494507b8e57b606137f7a95324
// ad 0x09e4eeaf5f43b84207bc5fd693b5b0b956ed5b3b20065341fa30dedd032a36bb
// contract 0x0d5db2711f58b72a8524abd781904cd3a9a72693dfdaf239f123110ef3bfc36b
contract PrivateCounter {
    use dep::aztec::{
        context::{Context},
        note::{
            note_header::NoteHeader,
            utils as note_utils,
        },
        state_vars::map::Map,
    };
    use dep::value_note::{
            balance_utils,
            value_note::{
                ValueNoteMethods,
                VALUE_NOTE_LEN,
            },
    };
    use dep::easy_private_state::easy_private_state::EasyPrivateUint;

    struct Storage {
        counts: Map<EasyPrivateUint>,
    }

    impl Storage {
        fn init(context: Context) -> pub Self {
            Storage {
                counts: Map::new(
                    context,
                    1,
                    |context, slot| {
                        EasyPrivateUint::new(context, slot)
                    },
                ),
            }
        }
    }

    #[aztec(private)]
    fn constructor(initial_counter: u120, owner: Field) {
        let storage = Storage::init(Context::private(&mut context));
        storage.counts.at(owner).add(initial_counter, owner)
    }
    
    #[aztec(private)]
    fn increment(owner: Field) {
        let storage = Storage::init(Context::private(&mut context));
        storage.counts.at(owner).add(1, owner)
    }

    unconstrained fn get_counter(owner: Field) -> Field {
        let storage = Storage::init(Context::none());
        balance_utils::get_balance(storage.counts.at(owner).set)
    }

     unconstrained fn compute_note_hash_and_nullifier(
        contract_address: Field,
        nonce: Field,
        storage_slot: Field,
        preimage: [Field; VALUE_NOTE_LEN],
    ) -> [Field; 4] {
        let note_header = NoteHeader { contract_address, nonce, storage_slot };
        note_utils::compute_note_hash_and_nullifier(ValueNoteMethods, note_header, preimage)
    }
}
