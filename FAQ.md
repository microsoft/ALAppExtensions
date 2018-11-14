# Frequently asked questions
This topic provides answers to frequently asked questions, and will be updated regularly.

## How do I getting started as a contributer?
1. Become familiar with development in AL. For more information, see https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-get-started.  
2. Choose the sandbox option that's right for you. For more information, see https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sandbox-overview.  
3. Clone the repository where Microsoft extensions are available : https://github.com/Microsoft/ALAppExtensions.  
4. Objects are in the Microsoft ID range, which means you cannot upload the app to your sandbox. For the app to work you must renumber the object IDs (for more information, see https://blogs.msdn.microsoft.com/nav/2018/04/05/business-central-object-ranges/).  
    
    You can renumber objects in several ways. The following steps describe one of them.  
    
	1. Get the RenumberNavObjectIds tool from https://github.com/NAVDEMO/RenumberNavObjectIds.  
    2. Clone the project and open it in Visual Studio 2015. Build the project, and you are off to a good start.  
    3. Run the following PowerShell Script in PowerShell ISE:  
       ```
       Import-module "C:\...\RenumberObjectIds.dll"  
	   $RenumberList = @{}  
	   0..1000 | % { $RenumberList += @{ (1800+$_) = (80000+$_) } }  
	   0..20 | % { $RenumberList += @{ (136630+$_) = (82000+$_) } }  
		 
	   Renumber-NavObjectIds -SourceFolder "C:\...\C52012DataMigration\" -DestinationFolder "C:\...\C52012DataMigrationReID" -RenumberList $RenumberList -Verbose  
       ```
5. In Visual Studio Code, connect to your sandbox (follow the steps in the documentation that step 2 refers to) and open the C:\...\C52012DataMigration folder. Now you are ready to go. You can modify the code and build your extension.  
6. To submit your changes, create a new branch. Remember to revert the change of IDs, and then create a pull request. 

Have a look at the following articles for detailed walkthroughs:  
* https://blogs.msdn.microsoft.com/nav/2018/08/28/become-a-contributor-to-business-central/  
* https://blogs.msdn.microsoft.com/nav/2018/09/20/git-going-with-extensions/  

## Can I contribute by submiting my own app?
Currently we are accepting code contributions for published apps only.
 
## Some APIs files aren't available in Extensions V2. What to do?
Code that relies on temporary files must be rewritten to rely on InStream and OutStream data types instead. Code that relied on permanent files must be rewritten to use another form of permanent storage.
We are considering a virtualized temporary file system to make it possible to work with temporary files in the cloud at some point in the future.

## DotNet types are not available in Extensions V2. What now?
SaaS:  

DotNet interop is not available due to safety issues in running arbitrary .NET code on cloud servers. We recommend the following approaches to achieve your business scenario that previously relied on .NET:
1. With each monthly update we provide new AL types that replace the most typical usages of .NET, such as HTTP, JSON, XML, StringBuilder, Dictionaries and Lists. The new AL types can directly replace many of the .NET usages, which results in much cleaner code. For more information, see [HTTP, JSON, TextBuilder, and XML API Overview](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-restapi-overview).  
2. For things you can't do in AL code we recommend using Azure Functions to host the DLL or C# code that was previously embedded in NAV and call that service from AL. To get a more in-depth understanding, check out the following blog posts from our MVPs:  

* [State of .NET Affairs](http://vjeko.com/state-net-affairs/)  
* [AL support for REST Web Services](http://www.kauffmann.nl/2017/06/24/al-support-for-rest-web-services/)  
* [Invoking Azure Functions from AL](http://vjeko.com/invoking-azure-functions-al/)  

3. We offer an open source GitHub repository where you can submit .NET type wrappers that, if accepted, will be included in the base application. Here's a link to the repo [C/AL Open Library](https://github.com/Microsoft/cal-open-library).

On-Premise:  

We still encourage you to use the resources above to minimize your reliance on DotNet to make your solutions easily portable to the cloud. However, we are working on adding DotNet interop support to the new development environment, so eventually that will be available.

## Why can't I use the type or method 'XYZ' for 'Extension' development?
We've blocked a certain set of functions from being directly called from app code. Our approach was based on a conservative static analysis, and the result was that some functions are unnecessarily blocked. If you need to use one or more of these functions please log an issue and provide a full list. We will analyze your request and unblock the functions we deem to be safe.

## Will features from the latest release be back-ported to earlier releases?
Short answer: Only selected features.  

We have decided to focus our development efforts on a single, latest version of the product. Having said that, we will back-port selected features to the current release on a case-by-case basis. The decision depends on the costs/benefits of doing so and finding a balance between fixing issues that are truly blocking vs. developing new features for the latest version.

## What do all the labels assigned to issues mean?
We use labels for categorizing issues into types and tracking the issue lifecycle. Issues fall into the following types:  

* Enum-request - request an enum  
* Request-for-external - request to mark a function as external  
* Event-request - request for a new event  
* Extensibility-enhancement - larger suggestion improving extensibility, something we might want to consider in the future  

The lifecycle for issues is (mix of label + milestone + open/closed state):  

* Ships-in-future-update  - the issue was fixed in our source code repository and ships in the next major release
* Call-for-contributors - we are looking for contributors willing to address reported bug/suggestion
* Wontfix - the issue will not be fixed probably because it is our of scope of the current repository

## How do I report an issue?
This GitHub repository is dedicated to handling issues with published apps and extensibility requests for the latest release of Business Central. If you run into an issue, open a support case. You can open Support Request to CSS through PartnerSource portal or contact your Service Account Manager (SAM) in the local subsidiary to understand what is included in your contract as of support incident and PAH (Partner Advisory Hours). Your SAM might also step by step direct you how to open a support request or how to get credentials if this is the first time for you or your company.

## How do I offer a suggestion?
Similar to the previous question, issues that aren't related to published apps or extensibility are not what this GitHub repository is intended for. In those cases please register your idea in one of the following resources:  

* For functional improvements, go to [Business Central - Ideas](https://experience.dynamics.com/ideas/list/?forum=e288ef32-82ed-e611-8101-5065f38b21f1)  
* For feature suggestions for AL compiler and developer tools, see [Github.com/Microsoft/AL](https://github.com/Microsoft/AL/issues) for feature suggestions for AL compiler and developer tools  
