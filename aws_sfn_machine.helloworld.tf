resource "aws_sfn_state_machine" "helloworld" {
  name     = "HelloWorld"
  role_arn = aws_iam_role.statemachine.arn

  definition = <<EOF
{
  "Comment": "A Hello World example demonstrating various state types of the Amazon States Language",
  "StartAt": "Pass",
  "States": {
    "Pass": {
      "Comment": "A Pass state passes its input to its output, without performing work. Pass states are useful when constructing and debugging state machines.",
      "Type": "Pass",
      "Next": "Hello World example?"
    },
    "Hello World example?": {
      "Comment": "A Choice state adds branching logic to a state machine. Choice rules can implement 16 different comparison operators, and can be combined using And, Or, and Not",
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.IsHelloWorldExample",
          "BooleanEquals": true,
          "Next": "Yes"
        },
        {
          "Variable": "$.IsHelloWorldExample",
          "BooleanEquals": false,
          "Next": "No"
        }
      ],
      "Default": "Yes"
    },
    "Yes": {
      "Type": "Pass",
      "Next": "Wait 3 sec"
    },
    "No": {
      "Type": "Fail",
      "Cause": "Not Hello World"
    },
    "Wait 3 sec": {
      "Comment": "A Wait state delays the state machine from continuing for a specified time.",
      "Type": "Wait",
      "Seconds": 3,
      "Next": "Parallel State"
    },
    "Parallel State": {
      "Comment": "A Parallel state can be used to create parallel branches of execution in your state machine.",
      "Type": "Parallel",
      "Next": "Hello World",
      "Branches": [
        {
          "StartAt": "Hello",
          "States": {
            "Hello": {
              "Type": "Pass",
              "End": true
            }
          }
        },
        {
          "StartAt": "World",
          "States": {
            "World": {
              "Type": "Pass",
              "End": true
            }
          }
        }
      ]
    },
    "Hello World": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF

  tags = { "createdby" = "James" }
}


resource "aws_iam_role" "statemachine" {
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "xray" {
  name = "xray_policy"
  role = aws_iam_role.statemachine.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "logs" {
  name = "logs_policy"
  role = aws_iam_role.statemachine.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries",
                "logs:PutResourcePolicy",
                "logs:DescribeResourcePolicies",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
