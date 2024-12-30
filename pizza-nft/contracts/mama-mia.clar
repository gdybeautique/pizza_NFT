;; Mama Mia's Pizza - An Italian-Themed NFT Collection Contract
;; This contract allows minting of artisanal pizza NFTs with Italian-inspired attributes

(define-non-fungible-token mama-mia uint)

;; Storage variables
(define-map pizza-attributes 
    { token-id: uint }
    { 
        crust: (string-ascii 20),
        topping: (string-ascii 20),
        size: uint,
        sauce: (string-ascii 20),
        rarity: (string-ascii 10)
    }
)
(define-map pizza-traits
    { token-id: uint }
    { 
        is-vegetarian: bool,
        is-spicy: bool,
        has-cheese: bool
    }
)

(define-data-var token-counter uint u0)
(define-data-var mint-price uint u50000000) ;; 0.5 STX
(define-data-var max-supply uint u1000)
(define-data-var base-uri (string-ascii 255) "https://mama-mia-nft.com/metadata/")
(define-data-var revealed bool false)
(define-map whitelist principal bool)
(define-data-var whitelist-mint-price uint u25000000) ;; 0.25 STX for whitelist
(define-data-var royalty-percent uint u5) ;; 5% royalty on secondary sales

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-sold-out (err u101))
(define-constant err-insufficient-funds (err u102))
(define-constant err-not-owner (err u103))
(define-constant err-already-minted (err u104))
(define-constant err-not-whitelisted (err u105))
(define-constant err-invalid-token (err u106))
(define-constant err-not-revealed (err u107))

;; Read-only functions
(define-read-only (get-last-token-id)
    (ok (var-get token-counter))
)

(define-read-only (get-owner (token-id uint))
    (nft-get-owner? mama-mia token-id)
)

(define-read-only (get-pizza-attributes (token-id uint))
    (map-get? pizza-attributes { token-id: token-id })
)

(define-read-only (get-pizza-traits (token-id uint))
    (map-get? pizza-traits { token-id: token-id })
)

(define-read-only (is-whitelisted (address principal))
    (default-to false (map-get? whitelist address))
)

;; Private functions
(define-private (get-random (seed uint))
    (mod (+ seed block-height) u1000)
)

(define-private (generate-attributes (token-id uint))
    (let (
        (random (get-random token-id))
        (crust-types (list "Thin" "Thick" "Stuffed" "Pan" "Neapolitan"))
        (topping-types (list "Pepperoni" "Margherita" "Mushroom" "Supreme" "BBQ"))
        (sauce-types (list "Tomato" "White" "Pesto" "BBQ" "Alfredo"))
        (rarity-types (list "Common" "Uncommon" "Rare" "Epic" "Legendary"))
    )
        {
            crust: (unwrap-panic (element-at crust-types (mod random u5))),
            topping: (unwrap-panic (element-at topping-types (mod (/ random u5) u5))),
            size: (+ u20 (mod random u11)), ;; 20-30 cm
            sauce: (unwrap-panic (element-at sauce-types (mod (/ random u25) u5))),
            rarity: (unwrap-panic (element-at rarity-types (mod (/ random u125) u5)))
        }
    )
)

(define-private (generate-traits (token-id uint))
    (let (
        (random (get-random token-id))
    )
        {
            is-vegetarian: (< (mod random u100) u30), ;; 30% chance
            is-spicy: (< (mod (/ random u100) u100) u10), ;; 10% chance
            has-cheese: (< (mod (/ random u10000) u100) u50) ;; 50% chance
        }
    )
)

;; Public functions
(define-public (mint-pizza)
    (let 
        (
            (current-supply (var-get token-counter))
            (new-token-id (+ current-supply u1))
            (caller tx-sender)
        )
        
        ;; Check max supply
        (asserts! (< current-supply (var-get max-supply)) err-sold-out)
        
        ;; Check payment
        (asserts! (>= (stx-get-balance caller) (var-get mint-price)) err-insufficient-funds)
        
        ;; Transfer mint price to contract owner
        (try! (stx-transfer? (var-get mint-price) caller contract-owner))
        
        ;; Mint NFT
        (try! (nft-mint? mama-mia new-token-id caller))
        
        ;; Generate and store attributes and traits
        (map-set pizza-attributes { token-id: new-token-id } (generate-attributes new-token-id))
        (map-set pizza-traits { token-id: new-token-id } (generate-traits new-token-id))
        
        ;; Update counter
        (var-set token-counter new-token-id)
        
        (ok new-token-id)
    )
)

(define-public (whitelist-mint)
    (let 
        (
            (current-supply (var-get token-counter))
            (new-token-id (+ current-supply u1))
            (caller tx-sender)
        )
        
        ;; Check whitelist
        (asserts! (is-whitelisted caller) err-not-whitelisted)
        
        ;; Check max supply
        (asserts! (< current-supply (var-get max-supply)) err-sold-out)
        
        ;; Check payment
        (asserts! (>= (stx-get-balance caller) (var-get whitelist-mint-price)) err-insufficient-funds)
        
        ;; Transfer mint price to contract owner
        (try! (stx-transfer? (var-get whitelist-mint-price) caller contract-owner))
        
        ;; Mint NFT
        (try! (nft-mint? mama-mia new-token-id caller))
        
        ;; Generate and store attributes and traits
        (map-set pizza-attributes { token-id: new-token-id } (generate-attributes new-token-id))
        (map-set pizza-traits { token-id: new-token-id } (generate-traits new-token-id))
        
        ;; Update counter
        (var-set token-counter new-token-id)
        
        ;; Remove from whitelist
        (map-delete whitelist caller)
        
        (ok new-token-id)
    )
)

;; Transfer function with royalties
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (let (
        (owner (unwrap! (nft-get-owner? mama-mia token-id) err-invalid-token))
    )
        (asserts! (is-eq tx-sender owner) err-not-owner)
        (if (is-eq sender owner)
            (try! (nft-transfer? mama-mia token-id sender recipient))
            (begin
                (try! (nft-transfer? mama-mia token-id sender recipient))
                (try! (stx-transfer? (/ (* (stx-get-balance tx-sender) (var-get royalty-percent)) u100) sender contract-owner))
            )
        )
        (ok true)
    )
)

;; Admin functions
(define-public (set-mint-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (var-set mint-price new-price)
        (ok true)
    )
)

(define-public (set-whitelist-mint-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (var-set whitelist-mint-price new-price)
        (ok true)
    )
)

(define-public (add-to-whitelist (address principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (map-set whitelist address true)
        (ok true)
    )
)

(define-public (remove-from-whitelist (address principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (map-delete whitelist address)
        (ok true)
    )
)

(define-public (set-base-uri (new-base-uri (string-ascii 255)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (var-set base-uri new-base-uri)
        (ok true)
    )
)

(define-public (reveal-collection)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (var-set revealed true)
        (ok true)
    )
)

(define-public (set-royalty-percent (new-percent uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (asserts! (<= new-percent u100) (err u108))
        (var-set royalty-percent new-percent)
        (ok true)
    )
)

(define-public (withdraw-funds)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (as-contract (stx-transfer? (stx-get-balance (as-contract tx-sender)) (as-contract tx-sender) contract-owner))
    )
)