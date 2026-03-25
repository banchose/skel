from IPython import get_ipython
from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.vi_state import InputMode

ip = get_ipython()


def switch_to_navigation_mode(event):
    event.app.vi_state.input_mode = InputMode.NAVIGATION


if getattr(ip, "pt_app", None):
    ip.pt_app.key_bindings.add("j", "j", filter=ViInsertMode())(
        switch_to_navigation_mode
    )
