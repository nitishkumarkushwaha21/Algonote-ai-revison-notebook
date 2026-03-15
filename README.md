# AlgoNote AI

A full-stack DSA revision platform that helps you:

- Organize problems like a mini IDE
- Import real LeetCode questions in seconds
- Write brute/better/optimal approaches side-by-side
- Build structured revision sheets from YouTube playlists
- Analyze your profile and weak areas

---

## Why AlgoNote

Most people use scattered tools for prep: browser tabs, notes apps, spreadsheets, random repos.
AlgoNote brings everything into one workflow:

1. Discover problems
2. Solve and document approaches
3. Track revision progress
4. Generate focused practice sets

---

## Main Features

### 1. Smart Problem Workspace

- Monaco-powered code editor
- Separate tabs for Brute, Better, Optimal
- Per-problem notes
- Difficulty, tags, and metadata storage

### 2. File Explorer Style Organization

- Folder/file tree inspired by IDE explorers
- Nested structures for topics and sheets
- Rename, delete, and revision state management

### 3. LeetCode Import

- Paste a LeetCode URL
- Automatically fetch:
  - Title
  - Difficulty
  - Description
  - Starter code snippets
  - Topic tags

### 4. YouTube Playlist to Revision Sheet

- Paste a playlist URL
- System maps each video to likely LeetCode problems
- Creates a structured sheet with links and metadata
- One-click import into explorer as ready-to-practice files

### 5. Profile Analysis and Recommendations

- Analyze LeetCode profile stats
- Highlight weak areas
- Generate topic-wise recommendations
- Import weak-area questions directly into explorer

### 6. Auth + User-Scoped Data

- Clerk-based authentication in frontend
- Token-based API calls
- User-aware file tree loading

---

## System Architecture

```mermaid
flowchart LR
    C[Client - React + Vite] --> G[API Gateway :5001]

    G --> F[File Service :5002]
    G --> P[Problem Service :5003]
    G --> A[AI Service :5004]
    G --> Y[YouTube Playlist Service :5005]
    G --> R[Profile Analysis Service :5006]

    F --> PG[(PostgreSQL)]
    P --> PG
    Y --> PG

    R --> MG[(MongoDB)]

    P --> LC[LeetCode GraphQL]
    Y --> YT[YouTube Data API]
    Y --> OR[OpenRouter / LLM]
    R --> LC
```

---

## Key User Flows

### Flow A: Import LeetCode Problem

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend
    participant GW as Gateway
    participant PS as Problem Service
    participant LC as LeetCode API

    U->>FE: Paste LeetCode URL
    FE->>GW: POST /api/problems/import
    GW->>PS: Forward request
    PS->>LC: Query by titleSlug
    LC-->>PS: Problem payload
    PS-->>FE: Normalized data
    FE->>GW: PUT /api/problems/:fileId
    GW->>PS: Save problem details
```

### Flow B: YouTube Playlist to Explorer

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend
    participant GW as Gateway
    participant YS as Playlist Service
    participant YT as YouTube API
    participant OR as OpenRouter
    participant PS as Problem Service
    participant FS as File Service

    U->>FE: Submit playlist URL
    FE->>GW: POST /api/youtube-playlist/import
    GW->>YS: Forward request
    YS->>YT: Fetch playlist videos
    YS->>OR: Map video titles to LeetCode slugs
    YS->>PS: Fetch full problem data
    YS-->>FE: Sheet with matched problems
    U->>FE: Click Add to Explorer
    FE->>GW: POST /api/youtube-playlist/sheet/:id/create-folder
    GW->>YS: Create folder flow
    YS->>FS: Create folder/files
    YS->>PS: Populate problem content
```

---

## Tech Stack

### Frontend

- React (Vite)
- React Router
- Zustand
- Tailwind CSS
- Monaco Editor
- Framer Motion
- Axios
- Clerk

### Backend

- Node.js + Express microservices
- API Gateway with proxy routing
- Sequelize + PostgreSQL
- Mongoose + MongoDB
- Service-to-service HTTP with Axios

### External Integrations

- LeetCode GraphQL API
- YouTube Data API v3
- OpenRouter (LLM model routing)

---

## Repository Layout

```text
.
├── client/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── store/
├── backend/
│   ├── gateway/
│   └── services/
│       ├── file-service/
│       ├── problem-service/
│       ├── ai-service/
│       ├── youtube-playlist-service/
│       └── profile-analysis-service/
├── docker-compose.yml
└── start-backend.ps1
```

---

## Quick Start

### 1. Install dependencies

```bash
npm install
cd client && npm install
cd ../backend/gateway && npm install
cd ../services/file-service && npm install
cd ../problem-service && npm install
cd ../ai-service && npm install
cd ../youtube-playlist-service && npm install
cd ../profile-analysis-service && npm install
```

### 2. Configure environment

Create required `.env` files for:

- database credentials
- API keys (LeetCode/OpenRouter/YouTube/OpenAI/Clerk as applicable)

### 3. Run locally

Backend (all services):

```bash
npm run start:backend
```

Frontend:

```bash
cd client
npm run dev
```

---

## Docker (Updated)

### Local Docker Build

Use this when you want to build images from source on your machine:

```bash
docker compose up --build
```

### AWS/Production Docker Run

Use the prebuilt image compose file for server deployment:

```bash
docker compose -f docker-compose.aws.yml up -d
```

The AWS compose file is image-only and uses restart policies for stable long-running environments.

### Services in Docker Stack

- client
- gateway
- file-service
- problem-service
- ai-service
- youtube-playlist-service
- profile-analysis-service
- mongodb

---

## AWS Deployment (EC2)

This repo now includes an EC2-oriented deployment path:

- `deploy/aws/ec2/setup-ec2.sh` - one-time Docker + Compose installation on Ubuntu EC2
- `deploy/aws/ec2/deploy.sh` - pull latest images and redeploy services
- `.github/workflows/deploy-aws-ec2.yml` - optional GitHub Actions deployment over SSH

### 1. Launch EC2

Recommended:

- Ubuntu 22.04 LTS
- t3.large or above
- 30GB+ storage

Security group inbound:

- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS, if TLS is configured)

### 2. Prepare Server

```bash
chmod +x deploy/aws/ec2/setup-ec2.sh
./deploy/aws/ec2/setup-ec2.sh
```

Then log out and log in again so docker group permissions apply.

### 3. Clone + Configure

```bash
sudo mkdir -p /opt/algonote
sudo chown -R $USER:$USER /opt/algonote
cd /opt/algonote
git clone <your-repo-url> .
```

Create required env files on the server:

- root `.env`
- `backend/services/ai-service/.env`
- `backend/services/youtube-playlist-service/.env`

### 4. Deploy Containers

```bash
chmod +x deploy/aws/ec2/deploy.sh
./deploy/aws/ec2/deploy.sh
```

### 5. Verify

```bash
docker compose -f docker-compose.aws.yml ps
docker compose -f docker-compose.aws.yml logs -f gateway
```

### 6. Optional CI/CD via GitHub Actions

If you use `.github/workflows/deploy-aws-ec2.yml`, configure these repo secrets:

- `AWS_EC2_HOST`
- `AWS_EC2_USER`
- `AWS_EC2_SSH_KEY`

Deployment workflow behavior:

- Trigger on push to `main` or manual dispatch
- SSH into EC2
- Pull latest code
- Run deploy script

---

## API Overview

- `GET /api/files` - Fetch file tree
- `POST /api/files` - Create file/folder
- `GET /api/problems/:fileId` - Get problem content
- `PUT /api/problems/:fileId` - Update problem content
- `POST /api/problems/import` - Import from LeetCode URL
- `POST /api/ai/*` - AI operations
- `POST /api/youtube-playlist/import` - Import playlist
- `POST /api/youtube-playlist/sheet/:id/create-folder` - Push sheet to explorer
- `GET /api/profile-analysis/:username` - Analyze profile
- `POST /api/profile-analysis/recommendations` - Topic recommendations

---

## Current Direction

This project is evolving into a complete interview-prep operating system:

- structured practice generation
- integrated solving and note-taking
- feedback loops from profile analytics
- one-click revision workflows

If you are preparing for coding interviews consistently, this setup is built to reduce friction and improve repetition quality.
