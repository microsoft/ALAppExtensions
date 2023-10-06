// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <Summary>
/// Enum that defines standard retention periods.
/// </Summary>
enum 3900 "Retention Period Enum" implements "Retention Period"
{
    Extensible = true;

    /// <Summary>
    /// The "Never Delete" value results in a retention period where records are never removed.
    /// </Summary>
    value(0; "Never Delete")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The Custom value can be used to create user defined retention periods.
    /// </Summary>
    value(1; "Custom")
    {
        Implementation = "Retention Period" = "Retention Period Custom Impl.";
    }
    /// <Summary>
    /// The "1 Week" value results in a retention period where records that are older than seven days are deleted.
    /// </Summary>
    value(2; "1 Week")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "1 Month" value results in a retention period where records that are older than one month are deleted.
    /// </Summary>
    value(3; "1 Month")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "3 Months" value results in a retention period where records that are older than three months are deleted.
    /// </Summary>
    value(4; "3 Months")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "6 Months" value results in a retention period where records that are older than six months are deleted.
    /// </Summary>
    value(5; "6 Months")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "1 Year" value results in a retention period where records that are older than one year are deleted.
    /// </Summary>
    value(6; "1 Year")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "5 Years" value results in a retention period where records that are older than five years are deleted.
    /// </Summary>
    value(7; "5 Years")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
    /// <Summary>
    /// The "28 Days" value results in a retention period where records that are older than twenty-eight days are deleted.
    /// </Summary>
    value(8; "28 Days")
    {
        Implementation = "Retention Period" = "Retention Period Impl.";
    }
}