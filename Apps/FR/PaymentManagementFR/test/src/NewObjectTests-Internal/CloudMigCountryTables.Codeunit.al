// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Sales.Document;

codeunit 144005 "Cloud Mig Country Tables"
{
    procedure GetTablesThatShouldBeCloudMigrated(var ListOfTablesToMigrate: List of [Integer])
    begin
        ListOfTablesToMigrate.Add(Database::"Bank Account Buffer FR");
        ListOfTablesToMigrate.Add(Database::"FR Acc. Schedule Line");
        ListOfTablesToMigrate.Add(Database::"FR Acc. Schedule Name");
        ListOfTablesToMigrate.Add(Database::"Payment Address FR");
        ListOfTablesToMigrate.Add(Database::"Payment Class FR");
        ListOfTablesToMigrate.Add(Database::"Payment Header Archive FR");
        ListOfTablesToMigrate.Add(Database::"Payment Header FR");
        ListOfTablesToMigrate.Add(Database::"Payment Line Archive FR");
        ListOfTablesToMigrate.Add(Database::"Payment Line FR");
        ListOfTablesToMigrate.Add(Database::"Payment Post. Buffer FR");
        ListOfTablesToMigrate.Add(Database::"Payment Status FR");
        ListOfTablesToMigrate.Add(Database::"Payment Step Ledger FR");
        ListOfTablesToMigrate.Add(Database::"Payment Step FR");
        ListOfTablesToMigrate.Add(Database::"Shipment Invoiced");
        ListOfTablesToMigrate.Add(Database::"Unreal. CV Ledg. Entry Buffer");
    end;
}