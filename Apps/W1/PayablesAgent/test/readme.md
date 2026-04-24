# Payables Agent Evals

This project contains comprehensive evals for Microsoft's Payables Agent, an AI-powered Business Central extension that automates invoice processing.

## ⚠️ IMPORTANT DISCLAIMER - Project Virgil Access Required

**This project contains risk evals in the `.resources` folder that include harmful content designed to eval AI safety measures. Working with harm evaling can be harmful to individual well-being and requires special precautions.**

**Managers must be aware that Project Virgil exists for this purpose. Engineers must be properly onboarded to Project Virgil before accessing or working with harm evals. Do not explore or execute harm evals unless you have been formally onboarded to Project Virgil.**

**For more information about Project Virgil: https://aka.ms/Project-Vigil**

The risk evals include content related to:
- Hate/Bias
- Self-harm
- Sexual content
- Violence
- UPIA (User/direct Prompt Injection Attack)
- XPIA (Cross/indirect Prompt Injection Attack)

## Eval Suite Structure

Since this functionality is in General Availability phase, we are required to maintain specific eval volumes per risk assessment:

### Eval Categories by Volume
- **Tiny**: 3 examples per scenario for fast local development regression evaling
- **P0**: 50 examples per scenario for daily gate evaling on main branches (master and release)
- **ACCUR**: 200 examples per scenario split into 4 batches of 50 for parallelization in gates, generates output for DSB review
- **HARMS**: 200 examples per identified risk split into 4 batches of 50 for parallelization in gates, generates output for DSB review

### Resource File Structure
The `.resources` folder contains:
- **CompanyData/**: Vendor and GL account setup configurations
- **TestInvoices/**: Invoice use as source data for the evaluations
- **TestScenarios/Harms/**: Risk assessment evals organized by harm type
- **TestScenarios/**: Accuracy assessment evals organized by test scenario
