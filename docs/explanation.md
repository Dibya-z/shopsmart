# ShopSmart Project Explanation

## 1. Architecture Overview
ShopSmart is a full-stack web application designed with a decoupled architecture.
- **Frontend**: A Single Page Application (SPA) built with React and Vite. It serves as the presentation layer, making asynchronous HTTP requests to the backend. It uses functional components and a centralized CSS file for a clean, responsive UI.
- **Backend**: A RESTful API built with Node.js and Express. It acts as the business logic layer, handling client requests, processing data, and communicating with the database.
- **Database**: SQLite is used for relational data storage, managed seamlessly through the Prisma ORM. Prisma provides a type-safe database client and handles migrations.

## 2. CI/CD Workflow
The project implements an automated Continuous Integration (CI) pipeline using **GitHub Actions**.
- **Push & Pull Requests**: The `.github/workflows/ci.yml` file defines a pipeline that triggers on all pushes and PRs. It ensures code quality by automatically installing dependencies, running the linter (ESLint), executing the test suites (Jest/Vitest), and verifying the build process for both the client and server. If any of these steps (e.g., bad code caught by the linter or failing tests) result in an error, the pipeline fails, blocking the PR.
- **Dependency Management**: A `.github/dependabot.yml` configuration is included to regularly check for outdated `npm` packages, ensuring the project remains secure and up to date.

## 3. Design Decisions
- **Prisma ORM**: Selected for its robust schema modeling and auto-generated database client, which speeds up development and reduces raw SQL errors.
- **Linting & Formatting**: Integrated ESLint (with Node/Jest environments) and Prettier. This enforces a consistent coding style across the project and catches syntax or structural issues early.
- **Testing Strategy**: 
  - **Unit Tests**: React components are tested using Vitest and React Testing Library. Backend controllers are tested using Jest by mocking the Prisma client, ensuring business logic works in isolation.
  - **Integration Tests**: Supertest is used to start the Express app and perform actual HTTP rounds against the SQLite database, validating the system-level behavior between the API and DB.

## 4. Challenges Faced
- **ESLint Versioning**: Encountered compatibility issues between the latest ESLint defaults (which use new Node.js APIs) and the system's Node.js version (v20.11.1). This was resolved by explicitly downgrading to the highly stable ESLint v8 and using the `.eslintrc.json` config format.
- **Prisma Engine Requirements**: Initializing Prisma v7 demanded Node >= 20.19. We immediately recognized the engine constraints and adopted Prisma v5, cleanly migrating the database on the existing Node runtime.
- **Idempotency**: Ensured all scripts in `package.json` (`npm run test`, `npm run lint`) and database setup scripts are idempotent, producing the identical effect regardless of how many times they run.
