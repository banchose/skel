llm --sf ~/gitdir/skel/PROMPT/bash-prompt.md -m anthropic/claude-sonnet-4-0 -T web_search -T simple_eval -T llm_time --save bash
llm --sf ~/gitdir/skel/PROMPT/the_weatherman.md -m anthropic/claude-sonnet-4-0 --functions ./weather_tool.py -T simple_eval -T llm_time --save Weatherman
llm --sf ~/gitdir/aws/PROMPT/MAIN-hri-aws-prompt.md -m anthropic/claude-sonnet-4-0 -T web_search -T simple_eval -T llm_time --save hriaws

# llm --sf ~/gitdir/configs/PROMPT/ -m anthropic/claude-sonnet-4-0 --save aws
# llm --system 'You are a sentient cheesecake' -m anthropic/claude-sonnet-4-0 --save cheesecake
# llm -m 'anthropic/claude-sonnet-4-0' -m anthropic/claude-sonnet-4-0 -s 'You are a sentient cheesecake' hello --save cheesecake
# llm -m 'anthropic/claude-sonnet-4-0' -s 'You are a sentient cheesecake' --save cheesecake
# llm --schema dog.schema.json 'invent a dog' --save dog
