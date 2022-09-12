class App:
    def __init__(self, interface):
        self.interface = interface
        self.interface._impl = self
        App.app = self  # Add a reference for the PythonAppDelegate class to use.

        asyncio.set_event_loop_policy(EventLoopPolicy())
        self.loop = asyncio.get_event_loop()

    def create(self):
        """ Calls the startup method on the interface """
        self.interface.startup()

    def open_document(self, fileURL):
        """ Add a new document to this app."""
        pass

    def main_loop(self):
        # Main loop is a no-op on iOS; the app loop is integrated with the
        # main iOS event loop.

        # The rest of this method will eventually be wrapped into
        # rubicon as the method `run_forever_cooperatively()`.
        # self.loop.run_forever_cooperatively(lifecycle=iOSLifecycle())
        # ==== start run_forever_cooperatively()
        self.loop._set_lifecycle(iOSLifecycle())

        if self.loop.is_running():
            raise RuntimeError(
                "Recursively calling run_forever is forbidden. "
                "To recursively run the event loop, call run().")

        self.loop._running = True
        from asyncio import events
        if hasattr(events, "_set_running_loop"):
            events._set_running_loop(self.loop)

        self.loop._lifecycle.start()
        # ==== end run_forever_cooperatively()

    def set_main_window(self, window):
        pass

    def show_about_dialog(self):
        self.interface.factory.not_implemented("App.show_about_dialog()")

    def exit(self):
        pass

    def set_on_exit(self, value):
        pass

    def add_background_task(self, handler):
        self.loop.call_soon(handler, self)

