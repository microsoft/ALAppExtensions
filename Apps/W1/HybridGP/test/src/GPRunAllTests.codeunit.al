codeunit 139669 "GP RunAllTests"
{
    trigger OnRun();

    var
        GPAccountTests: Codeunit "GP Account Tests";
        GPItemTests: Codeunit "GP Item Tests";
        GPDataMigrationTests: Codeunit "GP Data Migration Tests";
        GPTransactionTests: Codeunit "GP Transaction Tests";
        GPForecastingTests: Codeunit "GP Forecasting Tests";
    begin
        GPAccountTests.Run();
        GPDataMigrationTests.Run();
        GPTransactionTests.Run();
        GPItemTests.Run();
        GPForecastingTests.Run();
    end;
}