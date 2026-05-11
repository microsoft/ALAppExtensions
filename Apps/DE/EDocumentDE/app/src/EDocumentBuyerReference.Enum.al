// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

enum 13914 "E-Document Buyer Reference"
{
    Extensible = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Buyer Reference is resolved automatically via priority chain: Document field > Customer E-Invoice Routing No. > Your Reference.';
    ObsoleteTag = '29.0';

    value(1; "Your Reference")
    {
        Caption = 'Your Reference';
        ObsoleteState = Pending;
        ObsoleteReason = 'Buyer Reference is resolved automatically via priority chain: Document field > Customer E-Invoice Routing No. > Your Reference.';
        ObsoleteTag = '29.0';
    }
    value(2; "Customer Reference")
    {
        Caption = 'Customer Reference';
        ObsoleteState = Pending;
        ObsoleteReason = 'Buyer Reference is resolved automatically via priority chain: Document field > Customer E-Invoice Routing No. > Your Reference.';
        ObsoleteTag = '29.0';
    }
}
