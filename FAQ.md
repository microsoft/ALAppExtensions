# Frequently asked questions
This topic provides answers to frequently asked questions, and will be updated regularly.

## How do I getting started as a contributer?
 Visit the [Getting Started with Modules](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-getting-started) documentation. 

Have a look at the following articles for detailed walkthroughs:
* https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-new-module
* https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-change-a-module

## Can I contribute by submiting my own app?
We are accepting code contributions for published apps and modules, as well as new relevant modules for the System Application that adhere to the [Module Architecture](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-blueprint) guide.
 
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

3. You can submit .NET type wrapper pull requests that, if accepted, will be included in the System Application. 

On-Premise:  

We still encourage you to use the resources above to minimize your reliance on DotNet to make your solutions easily portable to the cloud. However, we are working on adding DotNet interop support to the new development environment, so eventually that will be available.

## Why can't I use the type or method 'XYZ' for 'Extension' development?
We've blocked a certain set of functions from being directly called from app code. Our approach was based on a conservative static analysis, and the result was that some functions are unnecessarily blocked. If you need to use one or more of these functions please log an issue and provide a full list. We will analyze your request and unblock the functions we deem to be safe.

## When are my reported issues going be released?
We’ve decided to focus our development efforts on delivering a single, latest version of the product. Having said that, we will backport selected requests related to extensibility, such as events, to the current release on a case-by-case basis. The decision depends on the costs and benefits of backporting the new things, and whether the issue is truly blocking. For more information about what we backport, see the label definitions in the next section.

## What do all the labels assigned to issues mean?
We use labels for categorizing issues into types and tracking the issue lifecycle. Issues fall into the following types:

* **Enum-request:** Request an enum. We implement these only in major releases.
* **Request-for-external:** Request to mark a function as external. We normally only implement these in major releases.
* **Event-request:** Request a new event. We implement these in major and usually next minor releases.
* **Extensibility-enhancement:** Larger suggestions for improving extensibility. We consider these for future releases.
* **Extensibility-bug:** Smaller suggestions for improving extensibility. We consider these for the current release.

The lifecycle for issues is a mix of label + milestone + open/closed state:

* **Ships-in-future-update:** The issue was fixed in our source code repository and ships in the next major release or, for events, the next minor update.
* **Call-for-contributors:** We're looking for contributors who are willing to address a reported bug or request.
* **Wontfix:** The issue will not be fixed, probably because it is out of the scope of the current repository.

## How do I report an issue?
This GitHub repository is dedicated to handling issues with published apps and extensibility requests for the latest release of Business Central. If you run into an issue, open a support case. You can open Support Request to CSS through PartnerSource portal or contact your Service Account Manager (SAM) in the local subsidiary to understand what is included in your contract as of support incident and PAH (Partner Advisory Hours). Your SAM might also step by step direct you how to open a support request or how to get credentials if this is the first time for you or your company.

## How do I offer a suggestion?
Similar to the previous question, issues that aren't related to published apps, system application or extensibility are not what this GitHub repository is intended for. In those cases please register your idea in one of the following resources:  

* For functional improvements, go to [Business Central - Ideas](https://experience.dynamics.com/ideas/list/?forum=e288ef32-82ed-e611-8101-5065f38b21f1)  
* For feature suggestions for AL compiler and developer tools, see [Github.com/Microsoft/AL](https://github.com/Microsoft/AL/issues)  
