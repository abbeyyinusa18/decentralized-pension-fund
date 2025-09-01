
;; title: pension-fund
;; version: 1.0.0
;; summary: Decentralized pension fund management smart contract
;; description: A comprehensive pension fund system for contribution collection,
;;              investment tracking, benefit calculations, and member transparency

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_MEMBER_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_INVESTMENT (err u104))
(define-constant ERR_EARLY_WITHDRAWAL (err u105))
(define-constant ERR_ALREADY_MEMBER (err u106))
(define-constant ERR_INVALID_STRATEGY (err u107))

(define-constant MIN_CONTRIBUTION u1000000) ;; 1 STX minimum contribution
(define-constant VESTING_PERIOD u52560000) ;; ~10 years in blocks
(define-constant MAX_INVESTMENT_PERCENTAGE u80) ;; 80% max investment allocation

;; Data Variables
(define-data-var total-fund-balance uint u0)
(define-data-var total-members uint u0)
(define-data-var total-contributions uint u0)
(define-data-var total-benefits-paid uint u0)
(define-data-var investment-strategy-id uint u1)
(define-data-var fund-performance-score uint u100) ;; out of 100
(define-data-var emergency-reserve-ratio uint u20) ;; 20% emergency reserve

;; Data Maps - Member Management
(define-map members
  principal
  {
    total-contributions: uint,
    contribution-count: uint,
    join-block: uint,
    vesting-complete: bool,
    benefit-eligibility: bool,
    last-activity-block: uint,
    member-status: (string-ascii 20)
  }
)

;; Contribution Records
(define-map contribution-history
  { member: principal, contribution-id: uint }
  {
    amount: uint,
    block-height: uint,
    contribution-type: (string-ascii 30),
    tax-year: uint
  }
)

;; Investment Portfolio
(define-map investment-portfolio
  uint ;; investment-id
  {
    investment-type: (string-ascii 50),
    amount-allocated: uint,
    expected-return: uint,
    risk-level: uint, ;; 1-10 scale
    start-block: uint,
    maturity-block: uint,
    current-value: uint,
    performance-rating: uint
  }
)

;; Benefit Calculations
(define-map benefit-records
  principal
  {
    calculated-benefit: uint,
    calculation-date: uint,
    years-of-service: uint,
    benefit-multiplier: uint,
    distribution-schedule: (string-ascii 30)
  }
)

;; Regulatory Compliance
(define-map compliance-reports
  uint ;; report-id
  {
    report-type: (string-ascii 50),
    reporting-period: uint,
    compliance-status: bool,
    audit-hash: (buff 32),
    submission-block: uint,
    regulatory-body: (string-ascii 100)
  }
)

;; Performance Tracking
(define-map performance-metrics
  uint ;; period-id
  {
    period-start: uint,
    period-end: uint,
    total-returns: uint,
    risk-adjusted-return: uint,
    benchmark-comparison: int,
    volatility-measure: uint,
    sharpe-ratio: uint
  }
)

;; Member Communication
(define-map member-communications
  { member: principal, message-id: uint }
  {
    message-type: (string-ascii 50),
    content-hash: (buff 32),
    timestamp: uint,
    priority-level: uint,
    read-status: bool
  }
)

;; Global counters
(define-data-var next-contribution-id uint u1)
(define-data-var next-investment-id uint u1)
(define-data-var next-report-id uint u1)
(define-data-var next-period-id uint u1)
(define-data-var next-message-id uint u1)

;; Public Functions

;; Member Registration
(define-public (register-member)
  (let
    (
      (caller tx-sender)
      (current-block block-height)
    )
    (asserts! (is-none (map-get? members caller)) ERR_ALREADY_MEMBER)
    (map-set members caller {
      total-contributions: u0,
      contribution-count: u0,
      join-block: current-block,
      vesting-complete: false,
      benefit-eligibility: false,
      last-activity-block: current-block,
      member-status: "active"
    })
    (var-set total-members (+ (var-get total-members) u1))
    (ok true)
  )
)

;; Contribution Management
(define-public (make-contribution (amount uint) (contribution-type (string-ascii 30)))
  (let
    (
      (caller tx-sender)
      (current-block block-height)
      (contribution-id (var-get next-contribution-id))
      (member-data (unwrap! (map-get? members caller) ERR_MEMBER_NOT_FOUND))
    )
    (asserts! (>= amount MIN_CONTRIBUTION) ERR_INVALID_AMOUNT)
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    
    ;; Update member record
    (map-set members caller
      (merge member-data {
        total-contributions: (+ (get total-contributions member-data) amount),
        contribution-count: (+ (get contribution-count member-data) u1),
        last-activity-block: current-block
      })
    )
    
    ;; Record contribution
    (map-set contribution-history { member: caller, contribution-id: contribution-id }
      {
        amount: amount,
        block-height: current-block,
        contribution-type: contribution-type,
        tax-year: (/ current-block u52560) ;; Approximate years
      }
    )
    
    ;; Update global counters
    (var-set total-fund-balance (+ (var-get total-fund-balance) amount))
    (var-set total-contributions (+ (var-get total-contributions) amount))
    (var-set next-contribution-id (+ contribution-id u1))
    
    (ok contribution-id)
  )
)

;; Investment Strategy Management
(define-public (create-investment (investment-type (string-ascii 50)) (amount uint) (expected-return uint) (risk-level uint) (maturity-blocks uint))
  (let
    (
      (investment-id (var-get next-investment-id))
      (current-block block-height)
      (max-investment-amount (/ (* (var-get total-fund-balance) MAX_INVESTMENT_PERCENTAGE) u100))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (<= amount max-investment-amount) ERR_INVALID_INVESTMENT)
    (asserts! (and (>= risk-level u1) (<= risk-level u10)) ERR_INVALID_INVESTMENT)
    
    (map-set investment-portfolio investment-id
      {
        investment-type: investment-type,
        amount-allocated: amount,
        expected-return: expected-return,
        risk-level: risk-level,
        start-block: current-block,
        maturity-block: (+ current-block maturity-blocks),
        current-value: amount,
        performance-rating: u50 ;; Initial neutral rating
      }
    )
    
    (var-set next-investment-id (+ investment-id u1))
    (ok investment-id)
  )
)

;; Benefit Calculation
(define-public (calculate-benefits (member principal))
  (let
    (
      (member-data (unwrap! (map-get? members member) ERR_MEMBER_NOT_FOUND))
      (years-of-service (/ (- block-height (get join-block member-data)) u52560))
      (base-benefit (get total-contributions member-data))
      (service-multiplier (+ u100 (* years-of-service u5))) ;; 5% per year
      (calculated-benefit (/ (* base-benefit service-multiplier) u100))
    )
    (asserts! (>= years-of-service u1) ERR_EARLY_WITHDRAWAL)
    
    (map-set benefit-records member
      {
        calculated-benefit: calculated-benefit,
        calculation-date: block-height,
        years-of-service: years-of-service,
        benefit-multiplier: service-multiplier,
        distribution-schedule: "monthly"
      }
    )
    
    ;; Update member eligibility
    (map-set members member
      (merge member-data { benefit-eligibility: true })
    )
    
    (ok calculated-benefit)
  )
)

;; Benefit Distribution
(define-public (distribute-benefits (member principal) (amount uint))
  (let
    (
      (member-data (unwrap! (map-get? members member) ERR_MEMBER_NOT_FOUND))
      (benefit-data (unwrap! (map-get? benefit-records member) ERR_MEMBER_NOT_FOUND))
      (contract-balance (stx-get-balance (as-contract tx-sender)))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (get benefit-eligibility member-data) ERR_NOT_AUTHORIZED)
    (asserts! (<= amount (get calculated-benefit benefit-data)) ERR_INVALID_AMOUNT)
    (asserts! (>= contract-balance amount) ERR_INSUFFICIENT_FUNDS)
    
    ;; Transfer benefits
    (try! (as-contract (stx-transfer? amount tx-sender member)))
    
    ;; Update records
    (var-set total-benefits-paid (+ (var-get total-benefits-paid) amount))
    (var-set total-fund-balance (- (var-get total-fund-balance) amount))
    
    (ok true)
  )
)

;; Performance Tracking
(define-public (update-performance-metrics (total-returns uint) (risk-adjusted-return uint) (benchmark-comparison int))
  (let
    (
      (period-id (var-get next-period-id))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    
    (map-set performance-metrics period-id
      {
        period-start: (- current-block u5256), ;; ~1 year ago
        period-end: current-block,
        total-returns: total-returns,
        risk-adjusted-return: risk-adjusted-return,
        benchmark-comparison: benchmark-comparison,
        volatility-measure: (if (> total-returns risk-adjusted-return) 
                           (- total-returns risk-adjusted-return) 
                           u0),
        sharpe-ratio: (if (> risk-adjusted-return u0) 
                       (/ (* total-returns u100) risk-adjusted-return) 
                       u0)
      }
    )
    
    ;; Update fund performance score
    (var-set fund-performance-score 
      (if (> benchmark-comparison 0)
        (if (> (+ (var-get fund-performance-score) u5) u100) u100 (+ (var-get fund-performance-score) u5))
        (if (< (var-get fund-performance-score) u5) u0 (- (var-get fund-performance-score) u5))
      )
    )
    
    (var-set next-period-id (+ period-id u1))
    (ok period-id)
  )
)

;; Regulatory Compliance
(define-public (submit-compliance-report (report-type (string-ascii 50)) (audit-hash (buff 32)) (regulatory-body (string-ascii 100)))
  (let
    (
      (report-id (var-get next-report-id))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    
    (map-set compliance-reports report-id
      {
        report-type: report-type,
        reporting-period: current-block,
        compliance-status: true,
        audit-hash: audit-hash,
        submission-block: current-block,
        regulatory-body: regulatory-body
      }
    )
    
    (var-set next-report-id (+ report-id u1))
    (ok report-id)
  )
)

;; Member Communication
(define-public (send-member-communication (member principal) (message-type (string-ascii 50)) (content-hash (buff 32)) (priority uint))
  (let
    (
      (message-id (var-get next-message-id))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (map-get? members member)) ERR_MEMBER_NOT_FOUND)
    
    (map-set member-communications { member: member, message-id: message-id }
      {
        message-type: message-type,
        content-hash: content-hash,
        timestamp: current-block,
        priority-level: priority,
        read-status: false
      }
    )
    
    (var-set next-message-id (+ message-id u1))
    (ok message-id)
  )
)

;; Update Investment Value
(define-public (update-investment-value (investment-id uint) (new-value uint) (performance-rating uint))
  (let
    (
      (investment-data (unwrap! (map-get? investment-portfolio investment-id) ERR_INVALID_INVESTMENT))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (<= performance-rating u100) ERR_INVALID_INVESTMENT)
    
    (map-set investment-portfolio investment-id
      (merge investment-data {
        current-value: new-value,
        performance-rating: performance-rating
      })
    )
    
    (ok true)
  )
)

;; Read-Only Functions

;; Get Member Information
(define-read-only (get-member-info (member principal))
  (map-get? members member)
)

;; Get Fund Statistics
(define-read-only (get-fund-stats)
  {
    total-balance: (var-get total-fund-balance),
    total-members: (var-get total-members),
    total-contributions: (var-get total-contributions),
    total-benefits-paid: (var-get total-benefits-paid),
    performance-score: (var-get fund-performance-score),
    emergency-reserve: (/ (* (var-get total-fund-balance) (var-get emergency-reserve-ratio)) u100)
  }
)

;; Get Investment Details
(define-read-only (get-investment-info (investment-id uint))
  (map-get? investment-portfolio investment-id)
)

;; Get Member Contributions
(define-read-only (get-contribution-history (member principal) (contribution-id uint))
  (map-get? contribution-history { member: member, contribution-id: contribution-id })
)

;; Get Benefit Information
(define-read-only (get-benefit-info (member principal))
  (map-get? benefit-records member)
)

;; Get Compliance Report
(define-read-only (get-compliance-report (report-id uint))
  (map-get? compliance-reports report-id)
)

;; Get Performance Metrics
(define-read-only (get-performance-metrics (period-id uint))
  (map-get? performance-metrics period-id)
)

;; Get Member Messages
(define-read-only (get-member-messages (member principal) (message-id uint))
  (map-get? member-communications { member: member, message-id: message-id })
)

;; Calculate Expected Benefits
(define-read-only (calculate-expected-benefits (member principal))
  (match (map-get? members member)
    member-data
    (let
      (
        (years-of-service (/ (- block-height (get join-block member-data)) u52560))
        (base-amount (get total-contributions member-data))
        (projected-multiplier (+ u100 (* years-of-service u5)))
        (expected-benefit (/ (* base-amount projected-multiplier) u100))
      )
      (ok expected-benefit)
    )
    ERR_MEMBER_NOT_FOUND
  )
)

;; Check Vesting Status
(define-read-only (check-vesting-status (member principal))
  (match (map-get? members member)
    member-data
    (let
      (
        (vesting-complete (>= (- block-height (get join-block member-data)) VESTING_PERIOD))
      )
      (ok {
        is-vested: vesting-complete,
        blocks-remaining: (if vesting-complete u0 (- VESTING_PERIOD (- block-height (get join-block member-data)))),
        join-block: (get join-block member-data)
      })
    )
    ERR_MEMBER_NOT_FOUND
  )
)

;; Get Portfolio Performance
(define-read-only (get-portfolio-performance)
  (let
    (
      (total-invested (fold + (map get-investment-values (list u1 u2 u3 u4 u5)) u0))
      (total-current-value (fold + (map get-current-values (list u1 u2 u3 u4 u5)) u0))
    )
    (ok {
      total-invested: total-invested,
      current-value: total-current-value,
      performance-score: (var-get fund-performance-score),
      roi-percentage: (if (> total-invested u0)
                        (/ (* (- total-current-value total-invested) u100) total-invested)
                        u0)
    })
  )
)

;; Private Helper Functions

;; Helper to get investment values for portfolio calculation
(define-private (get-investment-values (investment-id uint))
  (match (map-get? investment-portfolio investment-id)
    investment-data (get amount-allocated investment-data)
    u0
  )
)

;; Helper to get current values for portfolio calculation
(define-private (get-current-values (investment-id uint))
  (match (map-get? investment-portfolio investment-id)
    investment-data (get current-value investment-data)
    u0
  )
)

;; Fund Health Check
(define-read-only (get-fund-health)
  (let
    (
      (total-balance (var-get total-fund-balance))
      (emergency-reserve (/ (* total-balance (var-get emergency-reserve-ratio)) u100))
      (liquidity-ratio (if (> total-balance u0) (/ (* emergency-reserve u100) total-balance) u0))
    )
    (ok {
      fund-balance: total-balance,
      emergency-reserve: emergency-reserve,
      liquidity-ratio: liquidity-ratio,
      health-score: (var-get fund-performance-score),
      total-members: (var-get total-members)
    })
  )
)
