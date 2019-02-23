<?php declare(strict_types=1);

use App\Handler\EntryPointHandler;
use Nuvola\AwsLambdaFramework\Kernel;
use Nuvola\AwsLambdaFramework\Lambda\Request;

$headers = [];
$request = Request::createFromInvocation(
    "http://{$_ENV['AWS_LAMBDA_RUNTIME_API']}/2018-06-01/runtime/invocation/next",
    $headers
);

$kernel = new Kernel($_ENV['_HANDLER']);
$kernel->registerHandler(new EntryPointHandler()); // TODO: move to $kernel->boot() with DI

$response = $kernel->handle($request);
$response->send(
    "http://{$_ENV['AWS_LAMBDA_RUNTIME_API']}/2018-06-01/runtime/invocation/{$headers['Lambda-Runtime-Aws-Request-Id']}/response"
);
