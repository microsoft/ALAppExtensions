// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.Document;

tableextension 6101 "E-Doc. Sales Header" extends "Sales Header"
{
    fields
    {
        /// <summary>
        /// This field is used to determine if the E-document creation was triggered by action requiring the E-document to be sent via email.
        /// </summary>
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
            Editable = false;
            AllowInCustomizations = Never;
            Access = Internal;
        }
    }
}
