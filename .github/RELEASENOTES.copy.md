## Preview

Note that when using the preview version of AL-Go for GitHub, you need to Update your AL-Go system files, as soon as possible when told to do so.

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
