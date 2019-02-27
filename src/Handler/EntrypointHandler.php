<?php declare(strict_types=1);

namespace App\Handler;

use Nuvola\AwsLambdaFramework\HandlerInterface;
use Nuvola\AwsLambdaFramework\Lambda\JsonResponse;
use Nuvola\AwsLambdaFramework\Lambda\Request;
use Nuvola\AwsLambdaFramework\Lambda\Response;

class EntrypointHandler implements HandlerInterface
{
    public function __invoke(Request $request): Response
    {
        return new JsonResponse(
            [
                'version' => '1.0.0',
                'datetime' => (new \DateTime())->format('c'),
                'request' => [
                    'http' => $request->getHttpMethod(),
                    'path' => $request->getPath(),
                    'queryStringParameters' => $request->getQueryStringParameters()->getArrayCopy(),
                    'body' => $request->getBody(),
                ]
            ]
        );
    }
}
