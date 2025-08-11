#if not CLEANSCHEMA30
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

enum 6377 "E-Doc. Ext. Send Mode"
{
    Access = Internal;
    Extensible = false;
    ObsoleteReason = 'Use Avalara Send Mode.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Test)
    {
        Caption = 'Test';
    }
    value(2; Certification)
    {
        Caption = 'Certification';
    }
}
#endif