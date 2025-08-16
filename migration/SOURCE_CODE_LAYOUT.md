# Source Code Layout Strategy for Maybe Migration

## Overview

This document outlines the source code organization strategy for migrating Maybe from a Rails monolith to SPA + microservices architecture. The approach emphasizes gradual migration, code reuse, and maintaining development velocity during the transition.

## Repository Strategy

### Option A: Monorepo Approach (Recommended)
```
maybe-finance/
├── legacy/                           # Existing Rails monolith
│   ├── app/
│   ├── config/
│   ├── db/
│   └── ... (current structure)
├── services/                         # New microservices
│   ├── identity-service/
│   ├── account-service/
│   ├── transaction-service/
│   ├── integration-service/
│   ├── import-service/
│   ├── investment-service/
│   ├── analytics-service/
│   └── notification-service/
├── frontend/                         # New SPA application
│   ├── web-app/                     # React/Next.js application
│   └── shared-components/           # Reusable UI components
├── shared/                          # Cross-cutting concerns
│   ├── events/                      # Event schemas and contracts
│   ├── proto/                       # Protocol buffer definitions
│   ├── types/                       # TypeScript type definitions
│   └── utils/                       # Shared utilities
├── infrastructure/                  # DevOps and deployment
│   ├── kubernetes/
│   ├── docker/
│   ├── terraform/
│   └── monitoring/
├── tools/                          # Migration and development tools
│   ├── migration-scripts/
│   ├── data-validation/
│   └── code-generators/
└── docs/                          # Documentation
    ├── migration/
    ├── architecture/
    └── api/
```

### Option B: Multi-repo Approach
```
Organizations:
├── maybe-finance/legacy-monolith     # Existing Rails app
├── maybe-finance/frontend-spa        # New React/Vue app
├── maybe-finance/identity-service    # Individual service repos
├── maybe-finance/account-service
├── maybe-finance/transaction-service
├── maybe-finance/shared-contracts    # Event schemas, APIs
├── maybe-finance/infrastructure      # K8s, Terraform, etc.
└── maybe-finance/migration-tools     # Scripts and utilities
```

## Detailed Monorepo Structure (Recommended Approach)

### Legacy Rails Application
```
legacy/
├── app/
│   ├── controllers/
│   │   ├── api/                     # Keep existing API controllers
│   │   │   └── v1/                  # Maintain current API structure
│   │   ├── legacy_adapters/         # NEW: Adapters for service calls
│   │   │   ├── account_adapter.rb
│   │   │   ├── transaction_adapter.rb
│   │   │   └── integration_adapter.rb
│   │   └── migration_controllers/   # NEW: Migration-specific endpoints
│   │       ├── data_validation_controller.rb
│   │       └── service_cutover_controller.rb
│   ├── models/
│   │   ├── legacy/                  # NEW: Namespace for legacy models
│   │   │   ├── legacy_account.rb    # Renamed existing models
│   │   │   ├── legacy_transaction.rb
│   │   │   └── legacy_user.rb
│   │   ├── adapters/                # NEW: Service integration models
│   │   │   ├── account_service_client.rb
│   │   │   ├── transaction_service_client.rb
│   │   │   └── identity_service_client.rb
│   │   └── migration/               # NEW: Migration helpers
│   │       ├── data_migrator.rb
│   │       ├── dual_writer.rb
│   │       └── service_router.rb
│   ├── services/                    # Keep existing service classes
│   │   ├── legacy/                  # Move current services here
│   │   └── migration/               # NEW: Migration-specific services
│   │       ├── strangler_fig_service.rb
│   │       ├── data_sync_service.rb
│   │       └── validation_service.rb
│   └── views/                       # Keep existing views during transition
├── config/
│   ├── routes.rb                    # Updated with service routing
│   ├── database.yml                 # Multiple database configuration
│   └── services.yml                 # NEW: Service endpoint configuration
├── db/
│   ├── migrate_legacy/              # Existing migrations
│   └── migrate_services/            # NEW: Service-related migrations
├── lib/
│   ├── legacy/                      # Keep existing lib code
│   └── service_clients/             # NEW: HTTP clients for services
│       ├── base_service_client.rb
│       ├── account_service_client.rb
│       └── transaction_service_client.rb
└── spec/
    ├── legacy/                      # Existing tests
    ├── migration/                   # NEW: Migration tests
    └── integration/                 # NEW: Service integration tests
```

### Microservices Structure
```
services/
├── identity-service/
│   ├── src/
│   │   ├── controllers/
│   │   │   ├── auth.controller.ts
│   │   │   ├── users.controller.ts
│   │   │   └── families.controller.ts
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   ├── jwt.service.ts
│   │   │   └── family.service.ts
│   │   ├── models/
│   │   │   ├── user.model.ts
│   │   │   ├── session.model.ts
│   │   │   └── family.model.ts
│   │   ├── events/
│   │   │   ├── publishers/
│   │   │   │   ├── user-created.publisher.ts
│   │   │   │   └── user-updated.publisher.ts
│   │   │   └── handlers/
│   │   │       └── family-updated.handler.ts
│   │   ├── repositories/
│   │   │   ├── user.repository.ts
│   │   │   └── family.repository.ts
│   │   ├── dto/
│   │   │   ├── create-user.dto.ts
│   │   │   └── login.dto.ts
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts
│   │   │   └── rate-limit.middleware.ts
│   │   ├── config/
│   │   │   ├── database.config.ts
│   │   │   └── jwt.config.ts
│   │   └── main.ts
│   ├── test/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── e2e/
│   ├── migrations/
│   ├── seeds/
│   ├── docker/
│   │   ├── Dockerfile
│   │   └── docker-compose.yml
│   ├── k8s/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
│
├── account-service/
│   ├── src/
│   │   ├── controllers/
│   │   │   ├── accounts.controller.ts
│   │   │   └── balances.controller.ts
│   │   ├── services/
│   │   │   ├── account.service.ts
│   │   │   ├── balance-calculator.service.ts
│   │   │   └── sync.service.ts
│   │   ├── models/
│   │   │   ├── account.model.ts
│   │   │   ├── balance.model.ts
│   │   │   └── account-sync.model.ts
│   │   ├── events/
│   │   │   ├── publishers/
│   │   │   │   ├── account-created.publisher.ts
│   │   │   │   ├── balance-updated.publisher.ts
│   │   │   │   └── account-synced.publisher.ts
│   │   │   └── handlers/
│   │   │       ├── transaction-processed.handler.ts
│   │   │       └── plaid-sync-completed.handler.ts
│   │   ├── repositories/
│   │   │   ├── account.repository.ts
│   │   │   └── balance.repository.ts
│   │   ├── dto/
│   │   │   ├── create-account.dto.ts
│   │   │   └── update-balance.dto.ts
│   │   ├── aggregates/               # Domain-driven design
│   │   │   ├── account.aggregate.ts
│   │   │   └── balance.aggregate.ts
│   │   ├── sagas/                    # Distributed transaction handling
│   │   │   ├── account-creation.saga.ts
│   │   │   └── balance-sync.saga.ts
│   │   └── main.ts
│   ├── migrations/
│   ├── test/
│   ├── docker/
│   ├── k8s/
│   └── package.json
│
├── transaction-service/
│   ├── src/
│   │   ├── controllers/
│   │   │   ├── transactions.controller.ts
│   │   │   ├── categories.controller.ts
│   │   │   └── merchants.controller.ts
│   │   ├── services/
│   │   │   ├── transaction.service.ts
│   │   │   ├── categorization.service.ts
│   │   │   └── merchant-matching.service.ts
│   │   ├── models/
│   │   │   ├── transaction.model.ts
│   │   │   ├── category.model.ts
│   │   │   ├── merchant.model.ts
│   │   │   └── tag.model.ts
│   │   ├── events/
│   │   │   ├── publishers/
│   │   │   │   ├── transaction-created.publisher.ts
│   │   │   │   ├── transaction-categorized.publisher.ts
│   │   │   │   └── transaction-deleted.publisher.ts
│   │   │   └── handlers/
│   │   │       ├── account-created.handler.ts
│   │   │       └── import-completed.handler.ts
│   │   ├── event-store/              # Event sourcing implementation
│   │   │   ├── event-store.service.ts
│   │   │   ├── snapshot.service.ts
│   │   │   └── projection.service.ts
│   │   ├── projections/              # CQRS read models
│   │   │   ├── transaction-summary.projection.ts
│   │   │   └── category-spending.projection.ts
│   │   ├── command-handlers/         # CQRS command handling
│   │   │   ├── create-transaction.handler.ts
│   │   │   ├── update-transaction.handler.ts
│   │   │   └── delete-transaction.handler.ts
│   │   ├── query-handlers/           # CQRS query handling
│   │   │   ├── get-transactions.handler.ts
│   │   │   └── get-spending-summary.handler.ts
│   │   └── main.ts
│   └── ...
│
└── [other services follow similar pattern]
```

### Frontend SPA Structure
```
frontend/
├── web-app/                         # Main React/Next.js application
│   ├── src/
│   │   ├── components/
│   │   │   ├── accounts/
│   │   │   │   ├── AccountCard.tsx
│   │   │   │   ├── AccountList.tsx
│   │   │   │   └── AccountForm.tsx
│   │   │   ├── transactions/
│   │   │   │   ├── TransactionList.tsx
│   │   │   │   ├── TransactionForm.tsx
│   │   │   │   └── TransactionChart.tsx
│   │   │   ├── charts/               # Migrated D3.js components
│   │   │   │   ├── TimeSeriesChart.tsx
│   │   │   │   ├── DonutChart.tsx
│   │   │   │   └── SankeyChart.tsx
│   │   │   ├── layout/
│   │   │   │   ├── Header.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   └── Navigation.tsx
│   │   │   └── ui/                   # Design system components
│   │   │       ├── Button.tsx
│   │   │       ├── Input.tsx
│   │   │       ├── Modal.tsx
│   │   │       └── Card.tsx
│   │   ├── pages/                    # Next.js pages or React Router
│   │   │   ├── accounts/
│   │   │   ├── transactions/
│   │   │   ├── budgets/
│   │   │   ├── investments/
│   │   │   └── settings/
│   │   ├── hooks/                    # Custom React hooks
│   │   │   ├── useAccounts.ts
│   │   │   ├── useTransactions.ts
│   │   │   ├── useAuth.ts
│   │   │   └── useWebSocket.ts
│   │   ├── services/                 # API clients and business logic
│   │   │   ├── api/
│   │   │   │   ├── accounts.api.ts
│   │   │   │   ├── transactions.api.ts
│   │   │   │   └── auth.api.ts
│   │   │   ├── websocket/
│   │   │   │   ├── websocket.service.ts
│   │   │   │   └── event-handlers.ts
│   │   │   └── storage/
│   │   │       ├── local-storage.service.ts
│   │   │       └── session-storage.service.ts
│   │   ├── store/                    # State management (Redux/Zustand)
│   │   │   ├── slices/
│   │   │   │   ├── auth.slice.ts
│   │   │   │   ├── accounts.slice.ts
│   │   │   │   └── transactions.slice.ts
│   │   │   ├── middleware/
│   │   │   │   ├── api.middleware.ts
│   │   │   │   └── websocket.middleware.ts
│   │   │   └── store.ts
│   │   ├── utils/
│   │   │   ├── formatters.ts
│   │   │   ├── validators.ts
│   │   │   └── constants.ts
│   │   ├── types/                    # TypeScript type definitions
│   │   │   ├── account.types.ts
│   │   │   ├── transaction.types.ts
│   │   │   └── api.types.ts
│   │   ├── styles/                   # Tailwind CSS and global styles
│   │   │   ├── globals.css
│   │   │   ├── components.css
│   │   │   └── tailwind.config.js
│   │   └── main.tsx
│   ├── public/
│   │   ├── icons/
│   │   ├── images/
│   │   └── manifest.json
│   ├── test/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── utils/
│   ├── .storybook/                   # Component documentation
│   │   ├── main.js
│   │   └── preview.js
│   ├── package.json
│   ├── tsconfig.json
│   ├── next.config.js               # or vite.config.js
│   └── README.md
│
└── shared-components/               # Reusable UI library
    ├── src/
    │   ├── components/
    │   │   ├── forms/
    │   │   ├── charts/
    │   │   ├── navigation/
    │   │   └── feedback/
    │   ├── hooks/
    │   ├── utils/
    │   └── types/
    ├── storybook/
    ├── test/
    ├── dist/                        # Built components
    └── package.json
```

### Shared Code Structure
```
shared/
├── events/                          # Event schemas and contracts
│   ├── schemas/
│   │   ├── account-events.ts
│   │   ├── transaction-events.ts
│   │   ├── user-events.ts
│   │   └── integration-events.ts
│   ├── base/
│   │   ├── base-event.ts
│   │   ├── event-metadata.ts
│   │   └── event-envelope.ts
│   ├── publishers/
│   │   ├── base-publisher.ts
│   │   └── kafka-publisher.ts
│   ├── subscribers/
│   │   ├── base-subscriber.ts
│   │   └── kafka-subscriber.ts
│   └── validation/
│       ├── event-validator.ts
│       └── schema-registry.ts
│
├── proto/                           # Protocol buffer definitions
│   ├── account.proto
│   ├── transaction.proto
│   ├── user.proto
│   └── common.proto
│
├── types/                           # Shared TypeScript types
│   ├── domain/
│   │   ├── account.types.ts
│   │   ├── transaction.types.ts
│   │   ├── user.types.ts
│   │   └── money.types.ts
│   ├── api/
│   │   ├── request.types.ts
│   │   ├── response.types.ts
│   │   └── error.types.ts
│   └── events/
│       ├── base.types.ts
│       └── domain-events.types.ts
│
├── utils/                           # Shared utility functions
│   ├── money/
│   │   ├── currency-converter.ts
│   │   ├── money-formatter.ts
│   │   └── money-math.ts
│   ├── validation/
│   │   ├── schema-validator.ts
│   │   └── business-rules.ts
│   ├── encryption/
│   │   ├── crypto-utils.ts
│   │   └── jwt-utils.ts
│   ├── dates/
│   │   ├── date-formatter.ts
│   │   └── timezone-utils.ts
│   └── http/
│       ├── http-client.ts
│       ├── retry-policy.ts
│       └── circuit-breaker.ts
│
└── constants/
    ├── currencies.ts
    ├── account-types.ts
    ├── transaction-categories.ts
    └── error-codes.ts
```

### Infrastructure as Code
```
infrastructure/
├── kubernetes/
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── rbac.yaml
│   │   └── network-policies.yaml
│   ├── services/
│   │   ├── identity-service/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │   ├── secret.yaml
│   │   │   └── hpa.yaml
│   │   ├── account-service/
│   │   └── [other services]
│   ├── databases/
│   │   ├── postgresql.yaml
│   │   ├── redis.yaml
│   │   └── kafka.yaml
│   ├── monitoring/
│   │   ├── prometheus.yaml
│   │   ├── grafana.yaml
│   │   └── jaeger.yaml
│   ├── ingress/
│   │   ├── api-gateway.yaml
│   │   └── tls-certificates.yaml
│   └── overlays/
│       ├── development/
│       ├── staging/
│       └── production/
│
├── terraform/
│   ├── modules/
│   │   ├── kubernetes-cluster/
│   │   ├── database/
│   │   ├── networking/
│   │   └── monitoring/
│   ├── environments/
│   │   ├── development/
│   │   ├── staging/
│   │   └── production/
│   └── shared/
│       ├── variables.tf
│       └── outputs.tf
│
├── docker/
│   ├── base-images/
│   │   ├── node-base/
│   │   ├── go-base/
│   │   └── nginx-base/
│   ├── development/
│   │   └── docker-compose.yml
│   └── build/
│       ├── multi-stage.Dockerfile
│       └── build-scripts/
│
├── helm/
│   ├── charts/
│   │   ├── maybe-services/
│   │   ├── maybe-frontend/
│   │   └── maybe-infrastructure/
│   └── values/
│       ├── development.yaml
│       ├── staging.yaml
│       └── production.yaml
│
└── monitoring/
    ├── prometheus/
    │   ├── rules/
    │   └── alerts/
    ├── grafana/
    │   ├── dashboards/
    │   └── datasources/
    └── logging/
        ├── fluentd/
        └── elasticsearch/
```

### Migration Tools
```
tools/
├── migration-scripts/
│   ├── data-migration/
│   │   ├── users-migration.js
│   │   ├── accounts-migration.js
│   │   ├── transactions-migration.js
│   │   └── validation-scripts.js
│   ├── schema-migration/
│   │   ├── create-service-databases.sql
│   │   ├── add-foreign-keys.sql
│   │   └── remove-foreign-keys.sql
│   ├── event-migration/
│   │   ├── generate-historical-events.js
│   │   ├── event-store-setup.js
│   │   └── projection-rebuild.js
│   └── cutover-scripts/
│       ├── traffic-routing.js
│       ├── feature-flag-toggle.js
│       └── rollback-procedures.js
│
├── data-validation/
│   ├── consistency-checker.js
│   ├── balance-reconciliation.js
│   ├── transaction-integrity.js
│   └── performance-benchmarks.js
│
├── code-generators/
│   ├── service-scaffold/
│   │   ├── templates/
│   │   └── generator.js
│   ├── api-client-generator/
│   │   ├── openapi-generator.js
│   │   └── typescript-client.js
│   └── event-schema-generator/
│       ├── schema-templates/
│       └── generator.js
│
└── development/
    ├── local-setup/
    │   ├── setup-services.sh
    │   ├── seed-data.js
    │   └── start-dependencies.sh
    ├── testing/
    │   ├── integration-test-runner.js
    │   ├── load-testing.js
    │   └── chaos-testing.js
    └── monitoring/
        ├── health-check.js
        ├── metrics-collector.js
        └── alert-simulator.js
```

## Migration Workflow

### Phase 1: Setup Monorepo Structure
```bash
# 1. Create new repository structure
mkdir maybe-finance && cd maybe-finance

# 2. Move existing Rails app to legacy folder
git subtree push --prefix=legacy origin legacy-extraction
git subtree pull --prefix=legacy origin main --squash

# 3. Initialize service directories
mkdir -p services/{identity,account,transaction,integration,import,investment,analytics,notification}-service

# 4. Set up shared libraries
mkdir -p shared/{events,types,utils,constants}

# 5. Initialize frontend structure
mkdir -p frontend/{web-app,shared-components}

# 6. Set up infrastructure
mkdir -p infrastructure/{kubernetes,terraform,docker,monitoring}

# 7. Create migration tools
mkdir -p tools/{migration-scripts,data-validation,code-generators}
```

### Phase 2: Legacy Integration Points
```ruby
# legacy/app/models/migration/service_router.rb
class Migration::ServiceRouter
  def self.route_account_request(action, params)
    if feature_enabled?(:account_service)
      AccountServiceClient.new.send(action, params)
    else
      Legacy::Account.send(action, params)
    end
  end

  def self.route_transaction_request(action, params)
    if feature_enabled?(:transaction_service)
      TransactionServiceClient.new.send(action, params)
    else
      Legacy::Transaction.send(action, params)
    end
  end

  private

  def self.feature_enabled?(service)
    Rails.application.config.feature_flags[service]
  end
end
```

### Phase 3: Service Development Workflow
```typescript
// services/account-service/src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe());
  
  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Account Service API')
    .setDescription('Account management microservice')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);
  
  // Enable CORS for frontend
  app.enableCors({
    origin: process.env.FRONTEND_URL,
    credentials: true,
  });
  
  await app.listen(3001);
}
bootstrap();
```

### Phase 4: Frontend Development Workflow
```typescript
// frontend/web-app/src/services/api/accounts.api.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { Account, CreateAccountRequest } from '../../types/account.types';

export const accountsApi = createApi({
  reducerPath: 'accountsApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1/accounts',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ['Account'],
  endpoints: (builder) => ({
    getAccounts: builder.query<Account[], void>({
      query: () => '',
      providesTags: ['Account'],
    }),
    createAccount: builder.mutation<Account, CreateAccountRequest>({
      query: (account) => ({
        url: '',
        method: 'POST',
        body: account,
      }),
      invalidatesTags: ['Account'],
    }),
  }),
});

export const { useGetAccountsQuery, useCreateAccountMutation } = accountsApi;
```

## Development Environment Setup

### Docker Compose for Local Development
```yaml
# infrastructure/docker/development/docker-compose.yml
version: '3.8'
services:
  # Legacy Rails application
  legacy-app:
    build: 
      context: ../../../legacy
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/maybe_development
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  # Frontend SPA
  frontend:
    build:
      context: ../../../frontend/web-app
      dockerfile: Dockerfile.dev
    ports:
      - "3001:3001"
    volumes:
      - ../../../frontend/web-app:/app
      - /app/node_modules
    environment:
      - VITE_API_URL=http://localhost:3000

  # Microservices
  identity-service:
    build: ../../../services/identity-service
    ports:
      - "3002:3002"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/identity_service_development
      - JWT_SECRET=dev-secret
    depends_on:
      - postgres

  account-service:
    build: ../../../services/account-service
    ports:
      - "3003:3003"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/account_service_development
    depends_on:
      - postgres

  # Infrastructure
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  kafka:
    image: confluentinc/cp-kafka:latest
    ports:
      - "9092:9092"
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092
    depends_on:
      - zookeeper

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    ports:
      - "2181:2181"
    environment:
      - ZOOKEEPER_CLIENT_PORT=2181

volumes:
  postgres_data:
```

### Development Scripts
```bash
#!/bin/bash
# tools/development/start-local.sh

echo "🚀 Starting Maybe Finance local development environment..."

# Start infrastructure dependencies
docker-compose -f infrastructure/docker/development/docker-compose.yml up -d postgres redis kafka zookeeper

# Wait for dependencies to be ready
echo "⏳ Waiting for dependencies..."
sleep 10

# Start legacy Rails application
echo "🔧 Starting legacy Rails application..."
cd legacy && bundle exec rails server -p 3000 &

# Start frontend development server
echo "🎨 Starting frontend development server..."
cd frontend/web-app && npm run dev &

# Start microservices
echo "🔬 Starting microservices..."
cd services/identity-service && npm run dev &
cd services/account-service && npm run dev &

# Start API Gateway (Kong/Ambassador)
echo "🌐 Starting API Gateway..."
docker-compose -f infrastructure/docker/development/docker-compose.yml up -d api-gateway

echo "✅ Development environment started!"
echo "🌍 Frontend: http://localhost:3001"
echo "🔧 Legacy API: http://localhost:3000"
echo "🔐 Identity Service: http://localhost:3002"
echo "💰 Account Service: http://localhost:3003"
```

## Advantages of This Approach

### 1. **Gradual Migration**
- Legacy system remains functional throughout migration
- Services can be developed and tested independently
- Risk is minimized through incremental changes

### 2. **Code Reuse**
- Shared libraries prevent duplication
- Common patterns across services
- Consistent API contracts

### 3. **Developer Experience**
- Single repository for easy navigation
- Consistent tooling and build processes
- Simplified dependency management

### 4. **Deployment Flexibility**
- Services can be deployed independently
- Legacy system can be gradually phased out
- Feature flags enable safe rollouts

### 5. **Testing Strategy**
- Unit tests for each service
- Integration tests across services
- End-to-end tests for critical workflows
- Contract testing for API compatibility

## Migration Governance

### Code Review Process
```yaml
review_requirements:
  legacy_changes:
    - Must maintain backward compatibility
    - Require migration team approval
    - Document service routing changes

  service_changes:
    - API contract changes require approval
    - Event schema changes need versioning
    - Database migrations need review

  frontend_changes:
    - Component migrations need design review
    - API client changes need backend approval
    - Performance impact assessment
```

### Version Management
```json
{
  "legacy": {
    "version": "2.1.0",
    "deprecation_date": "2025-12-31"
  },
  "services": {
    "identity": "1.2.0",
    "account": "1.1.0",
    "transaction": "1.0.0"
  },
  "frontend": {
    "web-app": "2.0.0",
    "shared-components": "1.5.0"
  }
}
```

This source code layout provides a structured approach to the migration while maintaining development velocity and system reliability throughout the transition period.