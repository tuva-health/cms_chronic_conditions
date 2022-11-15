{% macro export_graph() %}

{% if execute %}
    {% for node in graph.nodes.values()
        | selectattr("resource_type", "in", ["model"])
    %}
    {{ log(node,True) }}
    {% endfor %}
{% endif %}

{% endmacro %}