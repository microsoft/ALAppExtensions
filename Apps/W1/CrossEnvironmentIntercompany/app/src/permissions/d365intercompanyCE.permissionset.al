namespace System.Security.AccessControl;

using Microsoft.Intercompany.Inbox;
using Microsoft.Intercompany.Comment;
using Microsoft.Intercompany.Dimension;
using Microsoft.Finance.Dimension;
using Microsoft.Intercompany.GLAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Intercompany.Partner;
using Microsoft.Intercompany.Setup;
using Microsoft.Intercompany.BankAccount;
using Microsoft.Bank.BankAccount;
using System.Threading;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using System.Environment;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Comment;
using Microsoft.Intercompany.DataExchange;

permissionset 30400 "D365 Intercompany CE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Dynamics 365 Business Central Intercompany Cross Environment';
    IncludedPermissionSets = "D365 BASIC";

    Permissions =
        tabledata "Handled IC Inbox Trans." = R,
        tabledata "IC Comment Line" = R,
        tabledata "IC Dimension" = R,
        tabledata Dimension = R,
        tabledata "IC Dimension Value" = R,
        tabledata "Dimension Value" = R,
        tabledata "IC Document Dimension" = R,
        tabledata "IC G/L Account" = R,
        tabledata "G/L Account" = R,
        tabledata "IC Inbox Jnl. Line" = R,
        tabledata "Handled IC Inbox Jnl. Line" = R,
        tabledata "IC Inbox Purchase Line" = R,
        tabledata "Handled IC Inbox Purch. Line" = R,
        tabledata "IC Inbox Purchase Header" = R,
        tabledata "Handled IC Inbox Purch. Header" = R,
        tabledata "IC Inbox Sales Header" = R,
        tabledata "Handled IC Inbox Sales Header" = R,
        tabledata "IC Inbox Sales Line" = R,
        tabledata "Handled IC Inbox Sales Line" = R,
        tabledata "IC Inbox Transaction" = R,
        tabledata "IC Inbox/Outbox Jnl. Line Dim." = R,
        tabledata "IC Partner" = R,
        tabledata "IC Setup" = R,
        tabledata "IC Bank Account" = R,
        tabledata "Bank Account" = R,
        tabledata "Job Queue Entry" = R,
        tabledata "Company Information" = R,
        tabledata "Purchase Header" = R,
        tabledata "Purch. Inv. Header" = R,
        tabledata Customer = R,
        tabledata Vendor = R,
        tabledata Company = R,
        tabledata "General Ledger Setup" = R,
        tabledata "Comment Line" = R,
        tabledata "Buffer IC Comment Line" = R,
        tabledata "Buffer IC Document Dimension" = R,
        tabledata "Buffer IC Inbox Jnl. Line" = R,
        tabledata "Buffer IC Inbox Purchase Line" = R,
        tabledata "Buffer IC Inbox Purch Header" = R,
        tabledata "Buffer IC Inbox Sales Header" = R,
        tabledata "Buffer IC Inbox Sales Line" = R,
        tabledata "Buffer IC Inbox Transaction" = R,
        tabledata "Buffer IC InOut Jnl. Line Dim." = R,
        tabledata "IC Incoming Notification" = RI,
        tabledata "IC Outgoing Notification" = RI;
}