// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using Microsoft.Intercompany.BankAccount;
using Microsoft.Intercompany.Comment;
using Microsoft.Intercompany.DataExchange;
using Microsoft.Intercompany.Dimension;
using Microsoft.Intercompany.GLAccount;
using Microsoft.Intercompany.Inbox;
using Microsoft.Intercompany.Partner;
using Microsoft.Intercompany.Setup;
using System.Environment.Configuration;
using System.Environment;

permissionset 30402 "Data Access IC CE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Access Intercompany Cross Environment ';

    Permissions =
        tabledata "User Personalization" = R,
        tabledata Company = R,
        tabledata "IC Setup" = R,
        tabledata "IC Partner" = R,
        tabledata "IC G/L Account" = R,
        tabledata "IC Dimension" = R,
        tabledata "IC Dimension Value" = R,
        tabledata "IC Bank Account" = R,
        tabledata "IC Inbox Transaction" = RiMD,
        tabledata "IC Inbox Jnl. Line" = RiD,
        tabledata "IC Inbox Purchase Header" = RiD,
        tabledata "IC Inbox Purchase Line" = RiD,
        tabledata "IC Inbox Sales Header" = RiD,
        tabledata "IC Inbox Sales Line" = RiD,
        tabledata "IC Inbox/Outbox Jnl. Line Dim." = RID,
        tabledata "IC Document Dimension" = RID,
        tabledata "IC Comment Line" = RID,
        tabledata "Handled IC Inbox Trans." = RI,
        tabledata "Handled IC Inbox Jnl. Line" = RI,
        tabledata "Handled IC Inbox Purch. Line" = RI,
        tabledata "Handled IC Inbox Purch. Header" = RI,
        tabledata "Handled IC Inbox Sales Header" = RI,
        tabledata "Handled IC Inbox Sales Line" = RI,
        tabledata "Buffer IC Inbox Transaction" = Rmd,
        tabledata "Buffer IC Inbox Jnl. Line" = Rmd,
        tabledata "Buffer IC Inbox Purch Header" = Rmd,
        tabledata "Buffer IC Inbox Purchase Line" = Rmd,
        tabledata "Buffer IC Inbox Sales Header" = Rmd,
        tabledata "Buffer IC Inbox Sales Line" = Rmd,
        tabledata "Buffer IC InOut Jnl. Line Dim." = Rmd,
        tabledata "Buffer IC Document Dimension" = Rmd,
        tabledata "Buffer IC Comment Line" = Rmd,
        tabledata "IC Incoming Notification" = RImd,
        tabledata "IC Outgoing Notification" = Rimd;
}