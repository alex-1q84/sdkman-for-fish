Feature: Support autoenv setting
    When the user sets `sdkman_auto_env=true`, we should always `use` the
    candidates specified in `./.sdkmanrc`, if any.

    Background:
        Given SDKMAN! candidate list is up to date
        And   candidate ant is installed at version 1.9.7
        And   candidate ant is installed at version 1.9.9
        And   candidate ant is installed at version 1.10.1
        And   candidate crash is installed at version 1.2.11
        And   candidate crash is installed at version 1.3.0

    Scenario: No action if autoenv turned off
        Given SDKMAN! config sets sdkman_auto_env to false
        And   file /tmp/autoenv-test/.sdkmanrc exists with content
            """
            ant=1.9.9
            """
        When we run fish script
            """
            echo (basename (realpath $ANT_HOME)) > /tmp/autoenv-test.log
            cd /tmp/autoenv-test
            echo (basename (realpath $ANT_HOME)) >> /tmp/autoenv-test.log
            cd ..
            echo (basename (realpath $ANT_HOME)) >> /tmp/autoenv-test.log
            """
        Then file /tmp/autoenv-test.log contains
            """
            1.10.1
            1.10.1
            1.10.1
            """

    Scenario: .sdkmanrc loaded if autoenv turned on
        Given SDKMAN! config sets sdkman_auto_env to true
        And   file /tmp/autoenv-test/.sdkmanrc exists with content
            """
            ant=1.9.9
            """
        When we run fish script
            """
            echo (basename (realpath $ANT_HOME)) > /tmp/autoenv-test.log
            cd /tmp/autoenv-test
            echo (basename (realpath $ANT_HOME)) >> /tmp/autoenv-test.log
            cd ..
            echo (basename (realpath $ANT_HOME)) >> /tmp/autoenv-test.log
            """
        Then file /tmp/autoenv-test.log contains
            """
            1.10.1
            1.9.9
            1.10.1
            """

    Scenario: Switching between directories with .sdkmanrc
        Given SDKMAN! config sets sdkman_auto_env to true
        And   file /tmp/autoenv-test-1/.sdkmanrc exists with content
            """
            ant=1.9.9
            crash=1.2.11
            """
        And   file /tmp/autoenv-test-2/.sdkmanrc exists with content
            """
            ant=1.9.7
            """
        When we run fish script
            """
            echo (basename (realpath $ANT_HOME)),(basename (realpath $CRASH_HOME)) > /tmp/autoenv-test.log
            cd /tmp/autoenv-test-1
            echo (basename (realpath $ANT_HOME)),(basename (realpath $CRASH_HOME)) >> /tmp/autoenv-test.log
            cd ../autoenv-test-2
            echo (basename (realpath $ANT_HOME)),(basename (realpath $CRASH_HOME)) >> /tmp/autoenv-test.log
            cd ..
            echo (basename (realpath $ANT_HOME)),(basename (realpath $CRASH_HOME)) >> /tmp/autoenv-test.log
            """
        Then file /tmp/autoenv-test.log contains
            """
            1.10.1,1.3.0
            1.9.9,1.2.11
            1.9.7,1.3.0
            1.10.1,1.3.0
            """
