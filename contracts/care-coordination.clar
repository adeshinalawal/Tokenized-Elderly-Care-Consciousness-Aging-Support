;; Care Coordination Contract
;; Manages consciousness-enhanced elderly care coordination

(define-map care-plans
  { plan-id: uint }
  {
    patient: principal,
    provider-id: uint,
    care-type: (string-ascii 30),
    start-date: uint,
    duration: uint,
    status: (string-ascii 20),
    consciousness-level: uint
  }
)

(define-data-var next-plan-id uint u1)

;; Create a new care plan
(define-public (create-care-plan
  (provider-id uint)
  (care-type (string-ascii 30))
  (duration uint)
  (consciousness-level uint))
  (let ((plan-id (var-get next-plan-id)))
    (map-set care-plans
      { plan-id: plan-id }
      {
        patient: tx-sender,
        provider-id: provider-id,
        care-type: care-type,
        start-date: block-height,
        duration: duration,
        status: "active",
        consciousness-level: consciousness-level
      }
    )
    (var-set next-plan-id (+ plan-id u1))
    (ok plan-id)
  )
)

;; Update care plan status
(define-public (update-plan-status (plan-id uint) (new-status (string-ascii 20)))
  (match (map-get? care-plans { plan-id: plan-id })
    plan-data
    (if (is-eq (get patient plan-data) tx-sender)
      (begin
        (map-set care-plans
          { plan-id: plan-id }
          (merge plan-data { status: new-status })
        )
        (ok true)
      )
      (err u403)
    )
    (err u404)
  )
)

;; Get care plan
(define-read-only (get-care-plan (plan-id uint))
  (map-get? care-plans { plan-id: plan-id })
)
