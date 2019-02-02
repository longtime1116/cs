function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


Y = zeros(m, num_labels); % [5000,10]
for i = 1:m
    Y(i,y(i)) = 1;
end


a1 = X;
z2 = [ones(m, 1), a1] * Theta1';
a2 = sigmoid(z2);
z3 = [ones(m, 1), a2] * Theta2';
h = sigmoid(z3);

cost = - Y .* log(h) - ((1 - Y) .* log(1 - h));

J = (1 / m) * sum(cost(:));


%size(X)     % [5000, 400]
%size(y)     % 5000, 1
%size(Y)     % [5000, 10]
%size(Theta1)% [25, 401]
%size(Theta2)% [10, 26]
%size(a1)    % [5000, 400]
%size(z2)    % [5000, 25]
%size(a2)    % [5000, 25]
%size(z3)    % [5000, 10]
%size(h)     % [5000, 10]
%size(cost)  % [5000, 10]


% part2

regTheta1 = sum((Theta1(:, 2:end) .* Theta1(:, 2:end))(:));
regTheta2 = sum((Theta2(:, 2:end) .* Theta2(:, 2:end))(:));
reg = lambda * (regTheta1 + regTheta2)  / (2 * m);

J = J + reg;


% part3
%size(Theta1)% [25, 401]
%size(Theta2)% [10, 26]
Delta2 = 0;
Delta1 = 0;
for i = 1:m
  % 1
  a1 = [1 X(i, :)];       % [1, 401]
  z2 = a1 * Theta1';      % [1, 25]
  a2 = [1 sigmoid(z2)];   % [1, 26]
  z3 = a2 * Theta2';      % [1, 10]
  a3 = sigmoid(z3);       % [1, 10]

  % 2
  delta3 = a3 - Y(i, :);   % [1. 10]

  % 3
  delta2 = (Theta2' * delta3')(2:end) .* sigmoidGradient(z2)'; % [25, 1]

  % 4
  Delta2 = Delta2 + delta3' * a2; % [10, 26]
  Delta1 = Delta1 + delta2 * a1;  % [25, 401]
end

Theta1_grad = Delta1 / m; % [25, 401]
Theta2_grad = Delta2 / m; % [10, 26]

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
