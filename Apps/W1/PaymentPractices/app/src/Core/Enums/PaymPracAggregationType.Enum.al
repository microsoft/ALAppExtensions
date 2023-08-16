enum 685 "Paym. Prac. Aggregation Type" implements PaymentPracticeLinesAggregator
{
    Extensible = true;

    value(1; Period)
    {
        Implementation = PaymentPracticeLinesAggregator = "Paym. Prac. Period Aggregator";
    }
    value(2; "Company Size")
    {
        Implementation = PaymentPracticeLinesAggregator = "Paym. Prac. Size Aggregator";
    }
}