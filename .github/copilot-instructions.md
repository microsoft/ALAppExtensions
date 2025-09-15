# GitHub Copilot Instructions for ALAppExtensions

## Repository Overview

This repository contains **Microsoft's AL application add-ons for Microsoft Dynamics 365 Business Central**. It hosts open-source extensions written in AL (Application Language) that extend Business Central functionality.

### High-Level Details
- **Size**: ~13,650 files, ~10,686 AL files
- **Languages**: Primarily AL (Application Language), PowerShell, JSON, YAML
- **Project Type**: AL extensions for Business Central ERP system
- **Target Runtime**: Microsoft Dynamics 365 Business Central (OnPrem and SaaS)
- **Framework**: AL-Go for GitHub (Microsoft's AL-based DevOps framework)
- **Architecture**: Modular AL applications organized by region/functionality

## Build and Validation Process

### Prerequisites
- **Docker**: Required for Business Central containers
- **PowerShell**: Version 7+ (pwsh command available)
- **AL-Go**: Microsoft's AL development framework (auto-managed via workflows)
- **Business Central artifacts**: Downloaded automatically during build

### Build Commands

#### Build Single Project
```powershell
# Use the root build script with project name
.\build.ps1 -ALGoProject "1st Party Apps (W1)" -AutoFill
.\build.ps1 -ALGoProject "1st Party Apps Tests (W1)" -AutoFill
```

#### Local Development Environment
```powershell
# Navigate to specific project
cd "Build/projects/1st Party Apps (W1)/.AL-Go"
.\localDevEnv.ps1 -containerName "bcserver" -auth "UserPassword" -credential $cred

# For tests
cd "Build/projects/1st Party Apps Tests (W1)/.AL-Go"
.\localDevEnv.ps1
```

### Testing
- **Test Execution**: Tests run automatically in AL-Go workflows
- **Test Projects**: Located in `Build/projects/1st Party Apps Tests (W1)`
- **Test Structure**: Each app has corresponding test folder in `Apps/W1/*/test/`
- **Manual Test Run**: Execute via localDevEnv.ps1 in test project

### Validation Pipeline
- **GitHub Workflows**: `.github/workflows/PullRequestHandler.yaml`
- **Validation Steps**:
  1. PR validation against linked GitHub issues
  2. AL-Go project compilation
  3. Ruleset validation (CodeCop, AppSourceCop, UICop, PTECop)
  4. Test execution for affected components
- **Rulesets**: Located in `Build/rulesets/` - always follow app.ruleset.json
- **Issue Linking**: PRs MUST link to approved GitHub issues or will be rejected

### Critical Build Requirements
1. **Always run builds in Docker containers** - AL compilation requires Business Central runtime
2. **Use AL-Go framework** - Don't attempt manual AL compilation
3. **Build time**: Initial builds can take 15-30+ minutes due to container setup
4. **Memory requirements**: Docker containers need 8GB+ RAM
5. **License files**: May be required for certain apps (specify 'none' if not available)

## Project Layout and Architecture

### Directory Structure
```
ALAppExtensions/
├── Apps/                     # Main application code
│   ├── W1/                  # Worldwide (W1) apps
│   ├── US/, CA/, GB/        # Country-specific localizations
│   └── ExtensionGroups.json # App grouping configuration
├── Build/                   # Build system and scripts
│   ├── projects/           # AL-Go project configurations
│   ├── rulesets/          # Code analysis rules
│   └── Scripts/           # Build and validation scripts
├── .github/               # GitHub workflows and templates
└── Other/                # Additional resources
```

### Key Configuration Files
- **AL-Go Settings**: `.github/AL-Go-Settings.json` - main build configuration
- **Project Settings**: `Build/projects/*/AL-Go/settings.json` - per-project config
- **App Manifests**: `Apps/*/app.json` - individual app configuration
- **Rulesets**: `Build/rulesets/app.ruleset.json` - code quality rules

### App Structure
Each AL app follows this pattern:
```
Apps/W1/AppName/
├── app/                 # Main app code
│   ├── app.json        # App manifest
│   └── src/            # AL source files
├── test/               # Test code (optional)
└── test library/       # Test utilities (optional)
```

### Critical Dependencies
- **AL-Go Actions**: Auto-updated GitHub actions for AL development
- **Business Central Artifacts**: Runtime downloaded from Microsoft
- **Container Helper**: BcContainerHelper PowerShell module
- **AL Compiler**: Managed by AL-Go framework

### Validation Checks
1. **Pre-commit**: Issue linking validation via `Build/Scripts/PullRequestValidation/`
2. **Compilation**: AL syntax and semantic validation
3. **Code Analysis**: Multiple rulesets (CodeCop, AppSourceCop, UICop, PTECop)
4. **Testing**: Automated test execution for modified components
5. **Dependency**: Cross-app dependency validation

## Key Development Guidelines

### Contributing Requirements
- **Issues First**: Must link PR to approved GitHub issue (see CONTRIBUTING.md)
- **BC Ideas**: Large features require approved BC Ideas from http://aka.ms/bcideas
- **CLA**: Microsoft Contributor License Agreement required for first contribution

### Code Standards
- **AL Language**: Follow Microsoft AL coding standards
- **Rulesets**: Always adhere to Build/rulesets/app.ruleset.json
- **ID Ranges**: Respect object ID ranges defined in app.json
- **Naming**: Use descriptive names following AL conventions
- **Events**: Prefer extensibility via events over direct modification

### Common Pitfalls to Avoid
1. **Never attempt builds without Docker** - AL requires Business Central runtime
2. **Don't modify base ruleset files** - Use app-specific overrides only
3. **Don't create PRs without linked issues** - Will be auto-rejected
4. **Don't skip AL-Go framework** - Manual compilation won't work
5. **Don't ignore ID range conflicts** - Check app.json idRanges before adding objects

### File Locations Reference
- Root build script: `build.ps1`
- Main documentation: `README.md`, `CONTRIBUTING.md`, `FAQ.md`
- Workflow definitions: `.github/workflows/`
- AL-Go configuration: `.github/AL-Go-Settings.json`
- Validation scripts: `Build/Scripts/PullRequestValidation/`
- Code rulesets: `Build/rulesets/`

## Trust These Instructions
These instructions are comprehensive and current. Only search for additional information if:
1. The instructions appear incomplete for your specific scenario
2. You encounter errors not covered in the common pitfalls
3. You need details about a specific app's functionality

The repository uses AL-Go framework extensively - trust the framework and these documented processes rather than attempting manual alternatives.