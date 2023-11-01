const AWS = require('aws-sdk');
const hruId = require('human-readable-ids').hri;

const DYNAMODB_TABLE = process.env.DYNAMODB_TABLE ?? 'snippets';

const dynamo = new AWS.DynamoDB.DocumentClient({
  region: process.env.AWS_DEFAULT_REGION,
  endpoint: process.env.AWS_ENDPOINT_URL,
});

const RESPONSE_MESSAGES = {
  BAD_REQUEST: 'Must specify snippet',
  NOT_FOUND: 'Snippet not found',
  INTERNAL_ERROR: 'Internal server error',
  RATE_LIMITED: 'Rate limited',
  DYNAMODB_LOAD_FAILURE: 'Unable to read from DynamoDB',
  DYNAMODB_SAVE_FAILURE: 'Unable to save to DynamoDB',
};

const createResponse = (statusCode, body) => ({
  statusCode: statusCode,
  body: JSON.stringify(body),
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Content-Type': 'application/json',
    'Access-Control-Allow-Methods': 'GET, POST',
    'Access-Control-Allow-Headers':
      'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
  },
});

exports.getSnippetByKey = async (snippet) => {
  const snippetEntry = {
    TableName: DYNAMODB_TABLE,
    Key: { snippet },
  };

  try {
    const result = await dynamo.get(snippetEntry).promise();
    if (result.Item) {
      return createResponse(200, result.Item);
    } else {
      return createResponse(404, { message: RESPONSE_MESSAGES.NOT_FOUND });
    }
  } catch (error) {
    console.error({ error });
    return createResponse(500, {
      message: RESPONSE_MESSAGES.DYNAMODB_LOAD_FAILURE,
    });
  }
};

exports.getSnippet = async (event) => {
  const { snippet } = event.queryStringParameters || {};

  if (!snippet) {
    return createResponse(400, { message: RESPONSE_MESSAGES.BAD_REQUEST });
  }

  return exports.getSnippetByKey(snippet);
};

exports.postSnippetContent = async (content) => {
  const snippetEntry = {
    TableName: DYNAMODB_TABLE,
    Item: { snippet: hruId.random(), content },
  };

  try {
    await dynamo.put(snippetEntry).promise();
    return snippetEntry.Item.snippet;
  } catch (error) {
    console.error({ error });
    return createResponse(500, {
      message: RESPONSE_MESSAGES.DYNAMODB_SAVE_FAILURE,
    });
  }
};

exports.postSnippet = async (event) => {
  const sourceIp = event.requestContext.identity.sourceIp;
  const { content } = JSON.parse(event.body);

  if (!content) {
    return createResponse(400, {
      message: RESPONSE_MESSAGES.BAD_REQUEST,
    });
  }

  const rateLimited = await areWeRateLimited(sourceIp);
  if (rateLimited) {
    return createResponse(403, {
      message: RESPONSE_MESSAGES.RATE_LIMITED,
    });
  }

  const id = exports.postSnippetContent(content);

  const okTime = Math.floor(Date.now() / 1000) + 10;
  const rateLimitEntry = {
    TableName: process.env.RATE_LIMIT_TABLE,
    Item: { ip: sourceIp, okTime: okTime, expiryTime: okTime },
  };

  try {
    await dynamo.put(rateLimitEntry).promise();
    return createResponse(200, { id });
  } catch (error) {
    console.error({ error });
    return createResponse(500, {
      message: RESPONSE_MESSAGES.DYNAMODB_SAVE_FAILURE,
    });
  }
};

const areWeRateLimited = async (sourceIp) => {
  const rateLimitEntry = {
    TableName: process.env.RATE_LIMIT_TABLE,
    Key: { ip: sourceIp },
  };

  try {
    const result = await dynamo.get(rateLimitEntry).promise();
    const okTime = result?.Item?.okTime;
    return okTime > Date.now() / 1000;
  } catch (error) {
    console.error('Error fetching from DynamoDB', error);
    throw new Error(RESPONSE_MESSAGES.INTERNAL_ERROR);
  }
};
