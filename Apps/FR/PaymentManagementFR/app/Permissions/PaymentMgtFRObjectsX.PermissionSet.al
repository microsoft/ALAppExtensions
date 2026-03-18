// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.Navigate;

permissionset 10838 "Payment Mgt FR - Objects X"
{
    Access = Internal;
    Assignable = false;
    Permissions = codeunit "Local Navigate Handler FR" = X,
                  codeunit "Payment Management FR" = X,
                  codeunit "Payment-Apply FR" = X,
                  codeunit "RIB Key FR" = X,
                  page "Payment Addresses FR" = X,
                  page "Payment Bank FR" = X,
                  page "Payment Bank Archive FR" = X,
                  page "Payment Class FR" = X,
                  page "Payment Class List FR" = X,
                  page "Payment Line Modification FR" = X,
                  page "Payment Lines Archive List FR" = X,
                  page "Payment Lines List FR" = X,
                  page "Payment Report FR" = X,
                  page "Payment Slip FR" = X,
                  page "Payment Slip Archive FR" = X,
                  page "Payment Slip List FR" = X,
                  page "Payment Slip List Archive FR" = X,
                  page "Payment Slip Subform FR" = X,
                  page "Payment Slip Subform ArchiveFR" = X,
                  page "Payment Status FR" = X,
                  page "Payment Status List FR" = X,
                  page "Payment Step Card FR" = X,
                  page "Payment Step Ledger FR" = X,
                  page "Payment Step Ledger List FR" = X,
                  page "Payment Steps FR" = X,
                  page "Payment Steps List FR" = X,
                  page "View/Edit Payment Line FR" = X,
                  xmlport "Import/Export Parameters FR" = X,
                  report "Archive Payment Slips FR" = X,
                  report "Bill FR" = X,
                  report "Draft FR" = X,
                  report "Draft notice FR" = X,
                  report "Draft recapitulation FR" = X,
                  report "Duplicate parameter FR" = X,
                  report "GL/Cust Ledger Reconciliation" = X,
                  report "GL/Vend Ledger Reconciliation" = X,
                  report "ETEBAC Files FR" = X,
                  report "Payment List FR" = X,
                  report "Remittance FR" = X,
                  report "SEPA ISO20022 FR" = X,
                  report "Suggest Cust. Payments" = X,
                  report "Suggest Vend. Payments" = X,
                  report "Withdraw FR" = X,
                  report "Withdraw notice FR" = X,
                  report "Withdraw recapitulation FR" = X,
                  report "Recapitulation Form FR" = X;
}