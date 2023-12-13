#if not CLEAN22
namespace Microsoft.CRM.EmailLoggin;

using System.Environment.Configuration;

enumextension 1680 "Feature To Update - Email Log." extends "Feature To Update"
{
    value(1680; EmailLoggingUsingGraphApi)
    {
        Implementation = "Feature Data Update" = "Feature Email Log. Using Graph";
        ObsoleteReason = 'Feature EmailLoggingUsingGraphApi will be enabled by default in version 22.0';
        ObsoleteState = Pending;
        ObsoleteTag = '22.0';
    }
}
#endif