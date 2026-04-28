# AI Development Toolkit — Dependency Graph

> Apps marked with `(MARKETPLACE)` are published on AppSource.

## Top-Level Structure

```
AI Development Toolkit (MARKETPLACE)
├── AI Development Toolkit - Design
│   ├── Agent Design Experience
│   └── Agent Samples
│       └── Agent Design Experience
├── AI Development Toolkit - Evaluation (MARKETPLACE)
│   ├── Agent Test Library
│   │   ├── AI Test Toolkit (MARKETPLACE)
│   │   │   ├── System Application
│   │   │   └── Test Runner
│   │   └── Library Assert
│   ├── AI Test Toolkit (MARKETPLACE)
│   │   ├── System Application
│   │   └── Test Runner
│   ├── Test Runner
│   ├── Any
│   ├── Library Variable Storage
│   │   └── Library Assert
│   ├── Library Assert
│   ├── Business Foundation Test Libraries
│   │   ├── System Application
│   │   └── Business Foundation
│   │       └── System Application
│   └── Application Test Library
│       ├── Any
│       ├── Library Assert
│       ├── Library Variable Storage
│       │   └── Library Assert
│       └── Business Foundation Test Libraries
│           ├── System Application
│           └── Business Foundation
│               └── System Application
└── Agent Samples Tests
    ├── Agent Samples (via Design)
    └── AI Development Toolkit - Evaluation (via Evaluation)
```

---

## AI Development Toolkit - Design

| App | ID | Dependencies |
|-----|----|--------------|
| **AI Development Toolkit - Design** | `f78952ee-aed3-43bb-896e-6598f98a3a35` | Agent Design Experience, Agent Samples |
| Agent Design Experience | `00155c68-8cdd-4d60-a451-2034ad094223` | *(none)* |
| Agent Samples | `698cfedb-66b9-44a8-b5ae-1ec18bd32fa7` | Agent Design Experience |

```
AI Development Toolkit - Design
├── Agent Design Experience
└── Agent Samples
    └── Agent Design Experience
```

**Unique dependencies (flat):** Agent Design Experience, Agent Samples

---

## AI Development Toolkit - Evaluation

| App | ID | Dependencies |
|-----|----|--------------|
| AI Development Toolkit - Evaluation (MARKETPLACE) | `517f890c-b49f-47de-8120-d0327974b89d` | | Agent Test Library, AI Test Toolkit, Test Runner, Any, Library Variable Storage, Library Assert, Business Foundation Test Libraries, Application Test Library |
| Agent Test Library | `5afe217e-507a-40b4-9aa5-f4325b6e8230` | AI Test Toolkit, Library Assert |
| AI Test Toolkit (MARKETPLACE) | `2156302a-872f-4568-be0b-60968696f0d5` | | System Application, Test Runner |
| Test Runner | `23de40a6-dfe8-4f80-80db-d70f83ce8caf` | *(none)* |
| Any | `e7320ebb-08b3-4406-b1ec-b4927d3e280b` | *(none)* |
| Library Variable Storage | `5095f467-0a01-4b99-99d1-9ff1237d286f` | Library Assert |
| Library Assert | `dd0be2ea-f733-4d65-bb34-a28f4624fb14` | *(none)* |
| Business Foundation Test Libraries | `bee8cf2f-494a-42f4-aabd-650e87934d39` | System Application, Business Foundation |
| Business Foundation | `f3552374-a1f2-4356-848e-196002525837` | System Application |
| System Application | `63ca2fa4-4f03-4f2b-a480-172fef340d3f` | *(none)* |
| Application Test Library | `d852d5d2-a39d-4179-baeb-f99a19e32510` | Any, Library Assert, Library Variable Storage, Business Foundation Test Libraries |

```
AI Development Toolkit - Evaluation (MARKETPLACE)
├── Agent Test Library
│   ├── AI Test Toolkit (MARKETPLACE)
│   │   ├── System Application
│   │   └── Test Runner
│   └── Library Assert
├── AI Test Toolkit (MARKETPLACE)
│   ├── System Application
│   └── Test Runner
├── Test Runner
├── Any
├── Library Variable Storage
│   └── Library Assert
├── Library Assert
├── Business Foundation Test Libraries
│   ├── System Application
│   └── Business Foundation
│       └── System Application
└── Application Test Library
    ├── Any
    ├── Library Assert
    ├── Library Variable Storage
    │   └── Library Assert
    └── Business Foundation Test Libraries
        ├── System Application
        └── Business Foundation
            └── System Application
```

**Unique dependencies (flat):** Agent Test Library, AI Test Toolkit (MARKETPLACE), Test Runner, Any, Library Variable Storage, Library Assert, Business Foundation Test Libraries, Business Foundation, System Application, Application Test Library

---

## Agent Samples Tests

| App | ID | Dependencies |
|-----|----|------------- |
| Agent Samples Tests | `f1ede36c-2f5f-47f1-ba20-258b509c0238` | Agent Samples, AI Development Toolkit - Evaluation |

Cross-cutting test app — depends on both Design (via Agent Samples) and Evaluation. Placed at the root level to preserve the Design/Evaluation separation.

---

## Leaf Nodes (no dependencies)

| App | ID |
|-----|----| 
| Test Runner | `23de40a6-dfe8-4f80-80db-d70f83ce8caf` |
| Any | `e7320ebb-08b3-4406-b1ec-b4927d3e280b` |
| Library Assert | `dd0be2ea-f733-4d65-bb34-a28f4624fb14` |
| System Application | `63ca2fa4-4f03-4f2b-a480-172fef340d3f` |
| Agent Design Experience | `00155c68-8cdd-4d60-a451-2034ad094223` |
