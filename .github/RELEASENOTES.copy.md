## Preview

Note that when using the preview version of AL-Go for GitHub, you need to Update your AL-Go system files, as soon as possible when told to do so.

### Issues

Issue 542 Deploy Workflow fails
Issue 558 CI/CD attempts to deploy from feature branch
Issue 559 Changelog includes wrong commits
Publish to AppSource fails if publisher name or app name contains national or special characters
Issue 598 Cleanup during flush if build pipeline doesn't cleanup properly
Issue 608 When creating a release, throw error if no new artifacts have been added
Issue 528 Give better error messages when uploading to storage accounts
Create Online Development environment workflow failed in AppSource template unless AppSourceCopMandatoryAffixes is defined in repository settings file
Create Online Development environment workflow didn't have a project parameter and only worked for single project repositories
Create Online Development environment workflow didn't work if runs-on was set to Linux
Special characters are not supported in RepoName, Project names or other settings - Use UTF8 encoding to handle special characters in GITHUB_OUTPUT and GITHUB_ENV

### Issue 555
AL-Go contains several workflows, which create a Pull Request or pushes code directly.
All (except Update AL-Go System Files) earlier used the GITHUB_TOKEN to create the PR or commit.
The problem using GITHUB_TOKEN is that is doesn't trigger a pull request build or a commit build.
This is by design: https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#triggering-a-workflow-from-a-workflow
Now, you can set the checkbox called Use GhTokenWorkflow to allowing you to use the GhTokenWorkflow instead of the GITHUB_TOKEN - making sure that workflows are triggered

### New Settings
- `keyVaultCodesignCertificateName`:  With this setting you can delegate the codesigning to an Azure Key Vault. This can be useful if your certificate has to be stored in a Hardware Security Module
- `PullRequestTrigger`:  With this setting you can set which trigger to use for Pull Request Builds. By default AL-Go will use pull_request_target.

### New Actions
- `DownloadProjectDependencies`: Downloads the dependency apps for a given project and build mode.

### Settings and Secrets in AL-Go for GitHub
In earlier versions of AL-Go for GitHub, all settings were available as individual environment variables to scripts and overrides, this is no longer the case.
Settings were also available as one compressed JSON structure in env:Settings, this is still the case.
Settings can no longer contain line breaks. It might have been possible to use line breaks earlier, but it would likely have unwanted consequences.
Use `$settings = $ENV:Settings | ConvertFrom-Json` to get all settings in PowerShell.

In earlier versions of AL-Go for GitHub, all secrets requested by AL-Go for GitHub were available as individual environment variables to scripts and overrides, this is no longer the case.
As described in bug 647, all secrets available to the workflow were also available in env:_Secrets, this is no longer the case.
All requested secrets were also available (base64 encoded) as one compressed JSON structure in env:Secrets, this is still the case.
Use `$secrets = $ENV:Secrets | ConvertFrom-Json` to get all requested secrets in PowerShell.
You cannot get to any secrets that weren't requested by AL-Go for GitHub.

## v3.1

### Issues

Issue #446 Wrong NewLine character in Release Notes
Issue #453 DeliverToStorage - override fails reading secrets
Issue #434 Use gh auth token to get authentication token instead of gh auth status
Issue #501 The Create New App action will now use 22.0.0.0 as default application reference and include NoImplicitwith feature.


### New behavior

The following workflows:

- Create New App
- Create New Test App
- Create New Performance Test App
- Increment Version Number
- Add Existing App
- Create Online Development Environment

All these actions now uses the selected branch in the **Run workflow** dialog as the target for the Pull Request or Direct COMMIT.

### New Settings

- `UseCompilerFolder`: Setting useCompilerFolder to true causes your pipelines to use containerless compiling. Unless you also set `doNotPublishApps` to true, setting useCompilerFolder to true won't give you any performance advantage, since AL-Go for GitHub will still need to create a container in order to publish and test the apps. In the future, publishing and testing will be split from building and there will be other options for getting an instance of Business Central for publishing and testing. 
- `vsixFile`: vsixFile should be a direct download URL to the version of the AL Language extension you want to use for building the project or repo. By default, AL-Go will use the AL Language extension that comes with the Business Central Artifacts.

### New Workflows

- **_BuildALGoProject** is a reusable workflow that unites the steps for building an AL-Go projects. It has been reused in the following workflows: _CI/CD_, _Pull Request Build_, _NextMinor_, _NextMajor_ and _Current_.
The workflow appears under the _Actions_ tab in GitHub, but it is not actionable in any way.  

### New Actions

- **DetermineArtifactUrl** is used to determine which artifacts to use for building a project in CI/CD, PullRequestHandler, Current, NextMinor and NextMajor workflows.

### License File

With the changes to the CRONUS license in Business Central version 22, that license can in most cases be used as a developer license for AppSource Apps and it is no longer mandatory to specify a license file in AppSource App repositories.
Obviously, if you build and test your app for Business Central versions prior to 21, it will fail if you don't specify a licenseFileUrl secret.

## v3.0

### **NOTE:** When upgrading to this version
When upgrading to this version form earlier versions of AL-Go for GitHub, you will need to run the _Update AL-Go System Files_ workflow twice if you have the `useProjectDependencies` setting set to _true_.

### Publish to unknown environment
You can now run the **Publish To Environment** workflow without creating the environment in GitHub or settings up-front, just by specifying the name of a single environment in the Environment Name when running the workflow.
Subsequently, if an AuthContext secret hasn't been created for this environment, the Device Code flow authentication will be initiated from the Publish To Environment workflow and you can publish to the new environment without ever creating a secret.
Open Workflow details to get the device Code for authentication in the job summary for the initialize job.

### Create Online Dev. Environment
When running the **Create Online Dev. Environment** workflow without having the _adminCenterApiCredentials_ secret created, the workflow will intiate the deviceCode flow and allow you to authenticate to the Business Central Admin Center.
Open Workflow details to get the device Code for authentication in the job summary for the initialize job.

### Issues
- Issue #391 Create release action - CreateReleaseBranch error
- Issue 434 Building local DevEnv, downloading dependencies: Authentication fails when using "gh auth status"

### Changes to Pull Request Process
In v2.4 and earlier, the PullRequestHandler would trigger the CI/CD workflow to run the PR build.
Now, the PullRequestHandler will perform the build and the CI/CD workflow is only run on push (or manual dispatch) and will perform a complete build.

### Build modes per project
Build modes can now be specified per project

### New Actions
- **DetermineProjectsToBuild** is used to determine which projects to build in PullRequestHandler, CI/CD, Current, NextMinor and NextMajor workflows.
- **CalculateArtifactNames** is used to calculate artifact names in PullRequestHandler, CI/CD, Current, NextMinor and NextMajor workflows.
- **VerifyPRChanges** is used to verify whether a PR contains changes, which are not allowed from a fork.

## v2.4

### Issues
- Issue #171 create a workspace file when creating a project
- Issue #356 Publish to AppSource fails in multi project repo
- Issue #358 Publish To Environment Action stopped working in v2.3
- Issue #362 Support for EnableTaskScheduler
- Issue #360 Creating a release and deploying from a release branch
- Issue #371 'No previous release found' for builds on release branches
- Issue #376 CICD jobs that are triggered by the pull request trigger run directly to an error if title contains quotes

### Release Branches
**NOTE:** Release Branches are now only named after major.minor if the patch value is 0 in the release tag (which must be semver compatible)

This version contains a number of bug fixes to release branches, to ensure that the recommended branching strategy is fully supported. Bugs fixed includes:
- Release branches was named after the full tag (1.0.0), even though subsequent hotfixes released from this branch would be 1.0.x
- Release branches named 1.0 wasn't picked up as a release branch
- Release notes contained the wrong changelog
- The previous release was always set to be the first release from a release branch
- SemVerStr could not have 5 segments after the dash
- Release was created on the right SHA, but the release branch was created on the wrong SHA

Recommended branching strategy:

![Branching Strategy](https://raw.githubusercontent.com/microsoft/AL-Go/main/Scenarios/images/branchingstrategy.png)

### New Settings
New Project setting: EnableTaskScheduler in container executing tests and when setting up local development environment

### Support for GitHub variables: ALGoOrgSettings and ALGoRepoSettings
Recently, GitHub added support for variables, which you can define on your organization or your repository.
AL-Go now supports that you can define a GitHub variable called ALGoOrgSettings, which will work for all repositories (with access to the variable)
Org Settings will be applied before Repo settings and local repository settings files will override values in the org settings
You can also define a variable called ALGoRepoSettings on the repository, which will be applied after reading the Repo Settings file in the repo
Example for usage could be setup of branching strategies, versioning or an appDependencyProbingPaths to repositories which all repositories share.
appDependencyProbingPaths from settings variables are merged together with appDependencyProbingPaths defined in repositories

### Refactoring and tests
ReadSettings has been refactored to allow organization wide settings to be added as well. CI Tests have been added to cover ReadSettings.

## v2.3

### Issues
- Issue #312 Branching enhancements
- Issue #229 Create Release action tags wrong commit
- Issue #283 Create Release workflow uses deprecated actions
- Issue #319 Support for AssignPremiumPlan
- Issue #328 Allow multiple projects in AppSource App repo
- Issue #344 Deliver To AppSource on finding app.json for the app
- Issue #345 LocalDevEnv.ps1 can't Dowload the file license file

### New Settings
New Project setting: AssignPremiumPlan on user in container executing tests and when setting up local development environment
New Repo setting: unusedALGoSystemFiles is an array of AL-Go System Files, which won't be updated during Update AL-Go System Files. They will instead be removed. Use with care, as this can break the AL-Go for GitHub functionality and potentially leave your repo no longer functional.

### Build modes support
AL-Go projects can now be built in different modes, by specifying the _buildModes_ setting in AL-Go-Settings.json. Read more about build modes in the [Basic Repository settings](https://github.com/microsoft/AL-Go/blob/main/Scenarios/settings.md#basic-repository-settings).

### LocalDevEnv / CloudDevEnv
With the support for PowerShell 7 in BcContainerHelper, the scripts LocalDevEnv and CloudDevEnv (placed in the .AL-Go folder) for creating development environments have been modified to run inside VS Code instead of spawning a new powershell 5.1 session.

### Continuous Delivery
Continuous Delivery can now run from other branches than main. By specifying a property called branches, containing an array of branches in the deliveryContext json construct, the artifacts generated from this branch are also delivered. The branch specification can include wildcards (like release/*). Default is main, i.e. no changes to functionality.

### Continuous Deployment
Continuous Deployment can now run from other branches than main. By creating a repo setting (.github/AL-Go-Settings.json) called **`<environmentname>-Branches`**, which is an array of branches, which will deploy the generated artifacts to this environment. The branch specification can include wildcards (like release/*), although this probably won't be used a lot in continuous deployment. Default is main, i.e. no changes to functionality.

### Create Release
When locating artifacts for the various projects, the SHA used to build the artifact is used for the release tag
If all projects are not available with the same SHA, this error is thrown: **The build selected for release doesn't contain all projects. Please rebuild all projects by manually running the CI/CD workflow and recreate the release.**
There is no longer a hard dependency on the main branch name from Create Release.

### AL-Go Tests
Some unit tests have been added and AL-Go unit tests can now be run directly from VS Code.
Another set of end to end tests have also been added and in the documentation on contributing to AL-Go, you can see how to run these in a local fork or from VS Code.

### LF, UTF8 and JSON
GitHub natively uses LF as line seperator in source files.
In earlier versions of AL-Go for GitHub, many scripts and actions would use CRLF and convert back and forth. Some files were written with UTF8 BOM (Byte Order Mark), other files without and JSON formatting was done using PowerShell 5.1 (which is different from PowerShell 7).
In the latest version, we always use LF as line seperator, UTF8 without BOM and JSON files are written using PowerShell 7. If you have self-hosted runners, you need to ensure that PS7 is installed to make this work.

### Experimental Support
Setting the repo setting "shell" to "pwsh", followed by running Update AL-Go System Files, will cause all PowerShell code to be run using PowerShell 7 instead of PowerShell 5. This functionality is experimental. Please report any issues at https://github.com/microsoft/AL-Go/issues
Setting the repo setting "runs-on" to "Ubuntu-Latest", followed by running Update AL-Go System Files, will cause all non-build jobs to run using Linux. This functionality is experimental. Please report any issues at https://github.com/microsoft/AL-Go/issues

## v2.2

### Enhancements
- Container Event log is added as a build artifact if builds or tests are failing

### Issues
- Issue #280 Overflow error when test result summary was too big
- Issue #282, 292 AL-Go for GitHub causes GitHub to issue warnings
- Issue #273 Potential security issue in Pull Request Handler in Open Source repositories
- Issue #303 PullRequestHandler fails on added files
- Issue #299 Multi-project repositories build all projects on Pull Requests
- Issue #291 Issues with new Pull Request Handler 
- Issue #287 AL-Go pipeline fails in ReadSettings step

### Changes
- VersioningStrategy 1 is no longer supported. GITHUB_ID has changed behavior (Issue #277)

## v2.1

### Issues
- Issue #233 AL-Go for GitHub causes GitHub to issue warnings
- Issue #244 Give error if AZURE_CREDENTIALS contains line breaks

### Changes
- New workflow: PullRequestHandler to handle all Pull Requests and pass control safely to CI/CD
- Changes to yaml files, PowerShell scripts and codeowners files are not permitted from fork Pull Requests
- Test Results summary (and failed tests) are now displayed directly in the CI/CD workflow and in the Pull Request Check

### Continuous Delivery
- Proof Of Concept Delivery to GitHub Packages and Nuget

## v2.0

### Issues
- Issue #143 Commit Message for **Increment Version Number** workflow
- Issue #160 Create local DevEnv aith appDependencyProbingPaths
- Issue #156 Versioningstrategy 2 doesn't use 24h format
- Issue #155 Initial Add existing app fails with "Cannot find path"
- Issue #152 Error when loading dependencies from releases
- Issue #168 Regression in preview fixed
- Issue #189 Warnings: Resource not accessible by integration
- Issue #190 PublishToEnvironment is not working with AL-Go-PTE@preview
- Issue #186 AL-GO build fails for multi-project repository when there's nothing to build
- When you have GitHub pages enabled, AL-Go for GitHub would try to publish to github_pages environment
- Special characters wasn't supported in parameters to GitHub actions (Create New App etc.)

### Continuous Delivery
- Added new GitHub Action "Deliver" to deliver build output to Storage or AppSource
- Refactor CI/CD and Release workflows to use new deliver action
- Custom delivery supported by creating scripts with the naming convention DeliverTo*.ps1 in the .github folder

### AppSource Apps
- New workflow: Publish to AppSource
- Continuous Delivery to AppSource validation supported

### Settings
- New Repo setting: CICDPushBranches can be specified as an array of branches, which triggers a CI/CD workflow on commit. Default is main', release/\*, feature/\*
- New Repo setting: CICDPullRequestBranches can be specified as an array of branches, which triggers a CI/CD workflow on pull request. Default is main
- New Repo setting: CICDSchedule can specify a CRONTab on when you want to run CI/CD on a schedule. Note that this will disable Push and Pull Request triggers unless specified specifically using CICDPushBranches or CICDPullRequestBranches
- New Repo setting: UpdateGitHubGoSystemFilesSchedule can specify a CRONTab on when you want to Update AL-Go System Files. Note that when running on a schedule, update AL-Go system files will perfom a direct commit and not create a pull request.
- New project Setting: AppSourceContext should be a compressed json structure containing authContext for submitting to AppSource. The BcContainerHelperFunction New-ALGoAppSourceContext will help you create this structure.
- New project Setting: AppSourceContinuousDelivery. Set this to true in enable continuous delivery for this project to AppSource. This requires AppSourceContext and AppSourceProductId to be set as well
- New project Setting: AppSourceProductId should be set to the product Id of this project in AppSource
- New project Setting: AppSourceMainAppFolder. If you have multiple appFolders, this is the folder name of the main app to submit to AppSource.

### All workflows
- Support 2 folder levels projects (apps\w1, apps\dk etc.)
- Better error messages for if an error occurs within an action
- Special characters are now supported in secrets
- Initial support for agents running inside containers on a host
- Optimized workflows to have fewer jobs

### Update AL-Go System Files Workflow
- workflow now displays the currently used template URL when selecting the Run Workflow action

### CI/CD workflow
- Better detection of changed projects
- appDependencyProbingPaths did not support multiple projects in the same repository for latestBuild dependencies
- appDependencyProbingPaths with release=latestBuild only considered the last 30 artifacts
- Use mutex around ReadSecrets to ensure that multiple agents on the same host doesn't clash
- Add lfs when checking out files for CI/CD to support checking in dependencies
- Continue on error with Deploy and Deliver

### CI/CD and Publish To New Environment
- Base functionality for selecting a specific GitHub runner for an environment
- Include dependencies artifacts when deploying (if generateDependencyArtifacts is true)

### localDevEnv.ps1 and cloudDevEnv.ps1
- Display clear error message if something goes wrong

## v1.5

### Issues
- Issue #100 - Add more resilience to localDevEnv.ps1 and cloudDevEnv.ps1
- Issue #131 - Special characters are not allowed in secrets

### All workflows
- During initialize, all AL-Go settings files are now checked for validity and reported correctly
- During initialize, the version number of AL-Go for GitHub is printed in large letters (incl. preview or dev.)

### New workflow: Create new Performance Test App
- Create BCPT Test app and add to bcptTestFolders to run bcpt Tests in workflows (set doNotRunBcptTests in workflow settings for workflows where you do NOT want this)

### Update AL-Go System Files Workflow
- Include release notes of new version in the description of the PR (and in the workflow output)

### CI/CD workflow
- Apps are not signed when the workflow is running as a Pull Request validation
- if a secret called applicationInsightsConnectionString exists, then the value of that will be used as ApplicationInsightsConnectionString for the app

### Increment Version Number Workflow
- Bugfix: increment all apps using f.ex. +0.1 would fail.

### Environments
- Add suport for EnvironmentName redirection by adding an Environment Secret under the environment or a repo secret called \<environmentName\>_EnvironmentName with the actual environment name.
- No default environment name on Publish To Environment
- For multi-project repositories, you can specify an environment secret called Projects or a repo setting called \<environment\>_Projects, containing the projects you want to deploy to this environment.

### Settings
- New setting: **runs-on** to allow modifying runs-on for all jobs (requires Update AL-Go System files after changing the setting)
- New setting: **DoNotSignApps** - setting this to true causes signing of the app to be skipped
- New setting: **DoNotPublishApps** - setting this to true causes the workflow to skip publishing, upgrading and testing the app to improve performance.
- New setting: **ConditionalSettings** to allow to use different settings for specific branches. Example:
```
    "ConditionalSettings": [
        {
            "branches": [ 
                "feature/*"
            ],
            "settings": {
                "doNotPublishApps":  true,
                "doNotSignApps":  true
            }
        }
    ]
```
- Default **BcContainerHelperVersion** is now based on AL-Go version. Preview AL-Go selects preview bcContainerHelper, normal selects latest.
- New Setting: **bcptTestFolders** contains folders with BCPT tests, which will run in all build workflows
- New Setting: set **doNotRunBcptTest** to true (in workflow specific settings file?) to avoid running BCPT tests
- New Setting: set **obsoleteTagMinAllowedMajorMinor** to enable appsource cop to validate your app against future changes (AS0105). This setting will become auto-calculated in Test Current, Test Next Minor and Test Next Major later.

## v1.4

### All workflows
- Add requested permissions to avoid dependency on user/org defaults being too permissive

### Update AL-Go System Files Workflow
- Default host to https://github.com/ (you can enter **myaccount/AL-Go-PTE@main** to change template)
- Support for "just" changing branch (ex. **\@Preview**) to shift to the preview version

### CI/CD Workflow
- Support for feature branches (naming **feature/\***) - CI/CD workflow will run, but not generate artifacts nor deploy to QA

### Create Release Workflow
- Support for release branches
- Force Semver format on release tags
- Add support for creating release branches on release (naming release/\*)
- Add support for incrementing main branch after release

### Increment version number workflow
- Add support for incremental (and absolute) version number change

### Environments
- Support environmentName redirection in CI/CD and Publish To Environments workflows
- If the name in Environments or environments settings doesn't match the actual environment name,
- You can add a secret called EnvironmentName under the environment (or \<environmentname\>_ENVIRONMENTNAME globally)


## v1.3

### Issues
- Issue #90 - Environments did not work. Secrets for environments specified in settings can now be **\<environmentname\>_AUTHCONTEXT**

### CI/CD Workflow
- Give warning instead of error If no artifacts are found in **appDependencyProbingPaths**

## v1.2

### Issues
- Issue #90 - Environments did not work. Environments (even if only defined in the settings file) did not work for private repositories if you didn't have a premium subscription.

### Local scripts
- **LocalDevEnv.ps1** and ***CloudDevEnv.ps1** will now spawn a new PowerShell window as admin instead of running inside VS Code. Normally people doesn't run VS Code as administrator, and they shouldn't have to. Furthermore, I have seen a some people having problems when running these scripts inside VS Code.


## v1.1

### Settings
- New Repo Setting: **GenerateDependencyArtifact** (default **false**). When true, CI/CD pipeline generates an artifact with the external dependencies used for building the apps in this repo.
- New Repo Setting: **UpdateDependencies** (default **false**). When true, the default artifact for building the apps in this repo is not the latest available artifacts for this country, but instead the first compatible version (after calculating application dependencies). It is recommended to run Test Current, Test NextMinor and Test NextMajor in order to test your app against current and future builds.

### CI/CD Workflow
- New Artifact: BuildOutput.txt. All compiler warnings and errors are emitted to this file to make it easier to investigate compiler errors and build a better UI for build errors and test results going forward.
- TestResults artifact name to include repo version number and workflow name (for Current, NextMinor and NextMajor)
- Default dependency version in appDependencyProbingPaths setting used is now latest Release instead of LatestBuild
