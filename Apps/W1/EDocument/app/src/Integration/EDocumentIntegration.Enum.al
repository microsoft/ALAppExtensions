// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Interfaces;

#if not CLEAN26
enum 6143 "E-Document Integration" implements "E-Document Integration", Sender, Receiver, "Default Int. Actions"
#else
enum 6143 "E-Document Integration" implements Sender, Receiver, "Default Int. Actions"
#endif
{
    Extensible = true;
#if not CLEAN26
    DefaultImplementation = Sender = "E-Document No Integration", Receiver = "E-Document No Integration", "Default Int. Actions" = "E-Document No Integration", "E-Document Integration" = "E-Document No Integration";
#else
    DefaultImplementation = Sender = "E-Document No Integration", Receiver = "E-Document No Integration", "Default Int. Actions" = "E-Document No Integration";
#endif

    value(0; "No Integration")
    {
#if not CLEAN26
        Implementation = "E-Document Integration" = "E-Document No Integration";
#else
        Implementation = Sender = "E-Document No Integration", Receiver = "E-Document No Integration", "Default Int. Actions" = "E-Document No Integration";
#endif
    }
}