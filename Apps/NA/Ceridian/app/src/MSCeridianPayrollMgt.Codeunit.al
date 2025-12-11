namespace Microsoft.Payroll.Ceridian;

using System.Environment.Configuration;

codeunit 1668 "MS Ceridian Payroll Mgt."
{
    var
        MSCeredianPayrollSetupTitleTxt: Label 'Set up Ceridian Payroll';
        MSCeredianPayrollSetupShortTitleTxt: Label 'Ceridian Payroll';
        MSCeredianPayrollSetupDescriptionTxt: Label 'Set up the Ceridian Payroll app and easily import payroll transactions from Ceridian HR/Payroll (US) and Ceridian Powerpay (Canada).';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', true, true)]
    local procedure InsertIntoMAnualSetupOnRegisterManualSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertManualSetup(MSCeredianPayrollSetupTitleTxt, MSCeredianPayrollSetupShortTitleTxt, MSCeredianPayrollSetupDescriptionTxt, 5, ObjectType::Page, Page::"MS - Ceridian Payroll Setup", "Manual Setup Category"::Finance, '', true);
    end;
}

