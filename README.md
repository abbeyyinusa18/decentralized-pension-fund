# Decentralized Pension Fund Management System

A comprehensive smart contract system built on Stacks blockchain for managing decentralized pension funds with full transparency, automated benefit calculations, and regulatory compliance.

## Overview

This project implements a decentralized pension fund management system that enables:

- **Member Registration & Contribution Tracking**: Secure registration and contribution management
- **Investment Strategy Management**: Portfolio allocation and performance tracking
- **Automated Benefit Calculations**: Dynamic benefit computation based on years of service
- **Regulatory Compliance**: Built-in compliance reporting and audit trails
- **Member Communication**: Transparent communication system for fund updates
- **Performance Analytics**: Real-time fund performance and health monitoring

## Architecture

The system is built using a single, comprehensive Clarity smart contract that manages:

### Core Data Structures

- **Members**: Principal-based member registry with contribution history
- **Contributions**: Historical record of all member contributions with tax year tracking
- **Investment Portfolio**: Multi-asset investment tracking with risk assessment
- **Benefit Records**: Calculated benefits with service-based multipliers
- **Compliance Reports**: Regulatory reporting with audit hash verification
- **Performance Metrics**: Time-series performance data with risk-adjusted returns

### Key Features

#### 1. Contribution Collection & Investment
- Minimum contribution threshold (1 STX)
- Automatic fund balance tracking
- Investment allocation with risk management (max 80% investment ratio)
- Emergency reserve maintenance (20% liquidity)

#### 2. Benefit Calculation & Distribution
- Service-based benefit multipliers (5% per year)
- Vesting period protection (~10 years)
- Automated eligibility determination
- Secure benefit distribution

#### 3. Investment Strategy & Performance Tracking
- Multi-investment portfolio management
- Risk level assessment (1-10 scale)
- Real-time performance scoring
- ROI calculation and benchmarking

#### 4. Regulatory Compliance & Reporting
- Audit hash submission for transparency
- Regulatory body tracking
- Compliance status monitoring
- Historical report archiving

#### 5. Member Communication & Transparency
- Priority-based messaging system
- Content hash verification
- Read status tracking
- Fund health transparency

## Contract Functions

### Public Functions

- `register-member()`: Register new pension fund member
- `make-contribution(amount, type)`: Submit pension contributions
- `create-investment(type, amount, return, risk, maturity)`: Create investment strategies
- `calculate-benefits(member)`: Calculate member benefits
- `distribute-benefits(member, amount)`: Distribute calculated benefits
- `update-performance-metrics(returns, risk-adjusted, benchmark)`: Update fund performance
- `submit-compliance-report(type, hash, body)`: Submit regulatory reports
- `send-member-communication(member, type, hash, priority)`: Send member updates
- `update-investment-value(id, value, rating)`: Update investment valuations

### Read-Only Functions

- `get-member-info(member)`: Retrieve member details
- `get-fund-stats()`: Get overall fund statistics
- `get-investment-info(id)`: Get investment details
- `get-contribution-history(member, id)`: Get contribution records
- `get-benefit-info(member)`: Get benefit calculations
- `get-compliance-report(id)`: Get compliance reports
- `get-performance-metrics(period)`: Get performance data
- `get-member-messages(member, id)`: Get member communications
- `calculate-expected-benefits(member)`: Project future benefits
- `check-vesting-status(member)`: Check member vesting status
- `get-portfolio-performance()`: Get portfolio performance summary
- `get-fund-health()`: Get fund health metrics

## Configuration

### Constants
- `MIN_CONTRIBUTION`: 1,000,000 microSTX (1 STX)
- `VESTING_PERIOD`: 52,560,000 blocks (~10 years)
- `MAX_INVESTMENT_PERCENTAGE`: 80% of fund balance
- `EMERGENCY_RESERVE_RATIO`: 20% liquidity requirement

### Error Codes
- `u100`: Not authorized
- `u101`: Invalid amount
- `u102`: Member not found
- `u103`: Insufficient funds
- `u104`: Invalid investment
- `u105`: Early withdrawal
- `u106`: Already member
- `u107`: Invalid strategy

## Development

### Prerequisites
- Clarinet CLI
- Node.js & npm
- Git

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd decentralized-pension-fund

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run tests
npm test
```

### Testing
The project includes comprehensive TypeScript tests covering:
- Member registration and contribution flows
- Investment strategy creation and management
- Benefit calculation accuracy
- Compliance reporting
- Performance tracking
- Error handling

## Security Considerations

- **Access Control**: Owner-only functions for fund management
- **Input Validation**: Comprehensive parameter validation
- **Fund Protection**: Emergency reserve requirements
- **Vesting Protection**: Early withdrawal prevention
- **Audit Trail**: Complete transaction history

## Regulatory Features

- **Audit Hash Verification**: Cryptographic proof of compliance documents
- **Regulatory Body Tracking**: Multi-jurisdiction compliance support
- **Historical Reporting**: Complete audit trail maintenance
- **Performance Disclosure**: Transparent fund performance reporting

## License

This project is developed for educational and demonstration purposes.
