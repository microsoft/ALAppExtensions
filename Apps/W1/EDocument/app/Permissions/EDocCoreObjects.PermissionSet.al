﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

permissionset 6100 "E-Doc. Core - Objects"
{
    Assignable = false;
    Access = Internal;
    Caption = 'E-Document Core - Objects';
    Permissions = table "E-Document" = X,
        table "E-Doc. Data Storage" = X,
        table "E-Document Log" = X,
        table "E-Document Integration Log" = X,
        table "E-Doc. Mapping" = X,
        table "E-Doc. Mapping Log" = X,
        table "E-Document Service" = X,
        table "E-Document Service Status" = X,
        codeunit "E-Document Import Job" = X,
        codeunit "E-Doc. Integration Management" = X,
        codeunit "E-Doc. Mapping" = X,
        codeunit "E-Document Background Jobs" = X,
        codeunit "E-Document Create Jnl. Line" = X,
        codeunit "E-Document Create Purch. Doc." = X,
        codeunit "E-Document Helper" = X,
        codeunit "E-Document Processing" = X,
        codeunit "E-Document Import Helper" = X,
        codeunit "E-Document Error Helper" = X,
        codeunit "E-Document Log" = X,
        codeunit "E-Doc. Export" = X,
        codeunit "E-Document No Integration" = X,
        codeunit "E-Document Subscription" = X,
        codeunit "E-Document Update Order" = X,
        codeunit "E-Document Workflow Setup" = X,
        codeunit "E-Document Created Flow" = X,
        codeunit "E-Document Get Response" = X,
        codeunit "E-Document Workflow Processing" = X,
        codeunit "E-Doc. Import" = X,
        codeunit "E-Document Create" = X,
        codeunit "E-Document Setup" = X,
        codeunit "E-Doc. Recurrent Batch Send" = X,
        page "E-Doc. Changes Part" = X,
        page "E-Doc. Changes Preview" = X,
        page "E-Document Activities" = X,
        page "E-Doc. Mapping Logs" = X,
        page "E-Doc. Mapping Part" = X,
        page "E-Document" = X,
        page "E-Document Logs" = X,
        page "E-Document Service" = X,
        page "E-Document Services" = X,
        page "E-Documents" = X,
        page "E-Document Service Status" = X,
        page "E-Document Integration Logs" = X;
}
