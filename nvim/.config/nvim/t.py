class cow:
    def __init__(self, hide: str) -> None:
        self.hide = hide

    def moo(self, x: str):
        print(x)


will = cow("raw")
