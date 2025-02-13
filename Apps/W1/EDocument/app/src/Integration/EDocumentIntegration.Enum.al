// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

#if CLEAN26
enum 6143 "E-Document Integration"
#else
enum 6143 "E-Document Integration" implements "E-Document Integration"
#endif
{
    ObsoleteTag = '26.0';
    ObsoleteState = Pending;
    ObsoleteReason = 'Use sender, receiver and action integration enums instead';

    Extensible = true;
    Access = Public;

#if not CLEAN26
    value(0; "No Integration")
    {
        ObsoleteReason = 'Use sender, receiver and action integration enums instead';
        ObsoleteState = Pending;
        ObsoleteTag = '26.0';
        Implementation = "E-Document Integration" = "E-Document No Integration";
    }
#endif
}