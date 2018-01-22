include("../src/JlMqtt.jl")

using Documenter, JlMQTT

makedocs(
    modules = [JlMQTT],
    format = :html,
    html_disable_git = true,
    sitename = "JlMQTT.jl",
    pages = [
        "Home" => "index.md",
        "Public Interface" => "publicinterface.md",
        "Networking" => "networking.md",
        "Messages" => "messages.md"
    ]
)
