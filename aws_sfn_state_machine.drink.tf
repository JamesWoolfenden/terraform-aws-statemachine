resource "aws_sfn_state_machine" "drink" {
  # checkov:skip=CKV_AWS_285: log group provisioning is out of scope for this example module
  name     = "my-drinks-machine"
  role_arn = aws_iam_role.statemachine.arn

  tracing_configuration {
    enabled = true
  }

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "MakeDrink",
  "States": {
    "MakeDrink": {
      "Type": "Choice",
      "Choices":[
          {"Variable":"$.drink","StringEquals":"tea","Next":"Tea"},
          {"Variable":"$.drink","StringEquals":"coffee","Next":"Coffee"}
      ],
      "Default": "Error"
    },
    "Tea": {"Type":"Pass", "End":true, "Result":"Lovely Tea"},
    "Coffee": {"Type":"Pass", "End":true, "Result":"Milky Coffee"},
    "Error": {"Type":"Pass", "End":true, "Result":"Error"}
  }
}
EOF
}
