using Flux
using Plots
using DataFrames
using CSV

function train_model(source)
    data = CSV.read(source; delim=',', decimal='.')
    features = data[["fixed acidity","volatile acidity","citric acid","residual sugar","chlorides","free sulfur dioxide","total sulfur dioxide","density","pH","sulphates","quality"]]
    target = data[[:alcohol]]
    data = ( dataframe_to_matrix(features), dataframe_to_matrix(target) )
    println(size(data[1]))
    println(size(data[2]))
    println(head(features, 10))
    println(head(target, 10))
    # create model
    model = Flux.Chain(Flux.Dense(11, 20, σ), Flux.Dense(20, 5, σ), Flux.Dense(5, 1) )
    # optimizer
    opt = Flux.Descent(0.01)
    # loss function σ
    loss(x, y) = Flux.mse(model(x), y)
    # losses
    losses = []
    # for each epochs
    for epoch in 1:5000
        Flux.train!(loss, params(model), [data], opt)
        # calculate new loss
        current_loss = loss(data...)
        println("Epoch: ", epoch, ", Loss: ", current_loss)
        push!(losses, current_loss)
    end

    display(plot(losses))
end

function dataframe_to_matrix(x)
    Matrix(Matrix(x)')
end
