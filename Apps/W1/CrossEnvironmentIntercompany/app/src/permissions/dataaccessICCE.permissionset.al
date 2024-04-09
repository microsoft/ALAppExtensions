// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
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
using System.Threading;
using System.Utilities;

permissionset 30402 "Data Access IC CE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Data Access Intercompany Cross Environment ';

    Permissions =
        tabledata "General Ledger Setup" = R,
        tabledata "User Personalization" = R,
        tabledata "Accounting Period" = R,
        tabledata User = R,
        tabledata Dimension = R,
        tabledata "Dimension Translation" = R,
        tabledata "Bank Account" = R,
        tabledata Company = R,
        tabledata "Company Information" = R,
        tabledata "Job Queue Entry" = RIMD,
        tabledata "Job Queue Log Entry" = RIMD,
        tabledata "Error Message Register" = RIMD,
        tabledata "Error Message" = RIMD,
        tabledata "Scheduled Task" = RIMD,
        tabledata "IC Setup" = R,
        tabledata "IC Partner" = R,
        tabledata "IC G/L Account" = R,
        tabledata "IC Dimension" = R,
        tabledata "IC Dimension Value" = R,
        tabledata "IC Bank Account" = R,
        tabledata "IC Inbox Transaction" = Ri,
        tabledata "IC Inbox Jnl. Line" = Ri,
        tabledata "IC Inbox Purchase Header" = Ri,
        tabledata "IC Inbox Purchase Line" = Ri,
        tabledata "IC Inbox Sales Header" = Ri,
        tabledata "IC Inbox Sales Line" = Ri,
        tabledata "IC Inbox/Outbox Jnl. Line Dim." = Ri,
        tabledata "IC Document Dimension" = Ri,
        tabledata "IC Comment Line" = Ri,
        tabledata "Handled IC Inbox Trans." = R,
        tabledata "Handled IC Inbox Jnl. Line" = R,
        tabledata "Handled IC Inbox Purch. Line" = R,
        tabledata "Handled IC Inbox Purch. Header" = R,
        tabledata "Handled IC Inbox Sales Header" = R,
        tabledata "Handled IC Inbox Sales Line" = R,
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