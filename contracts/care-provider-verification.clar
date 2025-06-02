;; Care Provider Verification Contract
;; Manages verification of consciousness aging care providers

(define-map providers
  { provider-id: uint }
  {
    address: principal,
    verified: bool,
    specialization: (string-ascii 50),
    rating: uint,
    active: bool
  }
)

(define-data-var next-provider-id uint u1)

;; Register a new care provider
(define-public (register-provider (specialization (string-ascii 50)))
  (let ((provider-id (var-get next-provider-id)))
    (map-set providers
      { provider-id: provider-id }
      {
        address: tx-sender,
        verified: false,
        specialization: specialization,
        rating: u0,
        active: true
      }
    )
    (var-set next-provider-id (+ provider-id u1))
    (ok provider-id)
  )
)

;; Verify a care provider (admin only)
(define-public (verify-provider (provider-id uint))
  (match (map-get? providers { provider-id: provider-id })
    provider-data
    (begin
      (map-set providers
        { provider-id: provider-id }
        (merge provider-data { verified: true })
      )
      (ok true)
    )
    (err u404)
  )
)

;; Get provider info
(define-read-only (get-provider (provider-id uint))
  (map-get? providers { provider-id: provider-id })
)

;; Check if provider is verified
(define-read-only (is-verified (provider-id uint))
  (match (map-get? providers { provider-id: provider-id })
    provider-data (get verified provider-data)
    false
  )
)
